import os
import random
import re
from datetime import datetime, timezone
from typing import Any

from flask import Flask, jsonify, request
from pymongo import ASCENDING, MongoClient
from pymongo.errors import DuplicateKeyError, PyMongoError

MONGO_URI = os.environ.get("MONGO_URI", "").strip()
MONGO_DB_NAME = os.environ.get("MONGO_DB_NAME", "simple_bank").strip()
PORT = int(os.environ.get("PORT", "5000"))

app = Flask(__name__)
mongo_client: MongoClient | None = None
users_collection = None


def serialise_user(document: dict[str, Any]) -> dict[str, Any]:
    created_at = document.get("created_at")
    return {
        "id": str(document.get("_id", "")),
        "full_name": document.get("full_name", ""),
        "email": document.get("email", ""),
        "phone": document.get("phone", ""),
        "account_number": document.get("account_number", ""),
        "account_type": document.get("account_type", "Savings"),
        "branch_name": document.get("branch_name", "Digital Branch"),
        "ifsc_code": document.get("ifsc_code", "SBNK0001001"),
        "balance": float(document.get("balance", 0.0)),
        "created_at": created_at.isoformat() if isinstance(created_at, datetime) else str(created_at or ""),
    }


def normalise_email(value: str) -> str:
    return value.strip().lower()


def valid_email(value: str) -> bool:
    return bool(re.fullmatch(r"[^@\s]+@[^@\s]+\.[^@\s]+", value))


def initialise_database() -> None:
    global mongo_client, users_collection
    if not MONGO_URI:
        raise RuntimeError("MONGO_URI environment variable is not configured")
    mongo_client = MongoClient(MONGO_URI, serverSelectionTimeoutMS=5000, connectTimeoutMS=5000)
    mongo_client.admin.command("ping")
    users_collection = mongo_client[MONGO_DB_NAME]["users"]
    users_collection.create_index([("email", ASCENDING)], unique=True)
    users_collection.create_index([("account_number", ASCENDING)], unique=True)


def collection():
    global users_collection
    if users_collection is None:
        initialise_database()
    return users_collection


@app.get("/api/health")
def health():
    try:
        collection().database.client.admin.command("ping")
        return jsonify(status="healthy", service="simple-bank-backend", database="connected")
    except Exception as exc:
        return jsonify(status="unhealthy", service="simple-bank-backend", database="disconnected", error=str(exc)), 503


@app.get("/api/users/lookup")
def lookup_user():
    email = normalise_email(request.args.get("email", ""))
    if not valid_email(email):
        return jsonify(message="A valid email address is required"), 400
    try:
        user = collection().find_one({"email": email})
    except PyMongoError:
        app.logger.exception("MongoDB lookup failed")
        return jsonify(message="Database request failed"), 503
    if user is None:
        return jsonify(exists=False, message="No account found. Please complete registration.")
    return jsonify(exists=True, message="Existing account found.", user=serialise_user(user))


@app.post("/api/register")
def register_user():
    payload = request.get_json(silent=True) or {}
    full_name = str(payload.get("full_name", "")).strip()
    email = normalise_email(str(payload.get("email", "")))
    phone = re.sub(r"\D", "", str(payload.get("phone", "")))
    account_type = str(payload.get("account_type", "Savings")).strip().title()

    errors = {}
    if len(full_name) < 3:
        errors["full_name"] = "Full name must contain at least 3 characters."
    if not valid_email(email):
        errors["email"] = "Enter a valid email address."
    if len(phone) != 10:
        errors["phone"] = "Enter a valid 10-digit mobile number."
    if account_type not in {"Savings", "Current"}:
        errors["account_type"] = "Account type must be Savings or Current."
    if errors:
        return jsonify(message="Validation failed", errors=errors), 400

    existing = collection().find_one({"email": email})
    if existing:
        return jsonify(created=False, exists=True, message="This user already exists.", user=serialise_user(existing))

    document = {
        "full_name": full_name,
        "email": email,
        "phone": phone,
        "account_number": f"SB{random.randint(1000000000, 9999999999)}",
        "account_type": account_type,
        "branch_name": "Digital Banking Branch",
        "ifsc_code": "SBNK0001001",
        "balance": 1000.00,
        "created_at": datetime.now(timezone.utc),
    }
    try:
        result = collection().insert_one(document)
        document["_id"] = result.inserted_id
    except DuplicateKeyError:
        existing = collection().find_one({"email": email})
        return jsonify(created=False, exists=True, message="This user already exists.", user=serialise_user(existing))
    except PyMongoError:
        app.logger.exception("MongoDB registration failed")
        return jsonify(message="Unable to create the account"), 503

    return jsonify(created=True, exists=False, message="Account created successfully.", user=serialise_user(document)), 201


@app.errorhandler(404)
def not_found(_error):
    return jsonify(message="API endpoint not found"), 404


if __name__ == "__main__":
    initialise_database()
    app.run(host="0.0.0.0", port=PORT)
