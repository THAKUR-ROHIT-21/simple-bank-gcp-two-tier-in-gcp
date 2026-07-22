FROM nginx:1.29-alpine
COPY index.html style.css app.js /usr/share/nginx/html/
COPY nginx/default.conf.template /etc/nginx/templates/default.conf.template
EXPOSE 80
