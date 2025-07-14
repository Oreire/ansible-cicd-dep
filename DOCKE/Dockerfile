FROM nginx:stable-alpine
COPY ./app /usr/share/nginx/html
#COPY ./app/style.css /usr/share/nginx/html/style.css
#COPY ./app/index.html /usr/share/nginx/html/index.html
#COPY ./app/script.js /usr/share/nginx/html/script.js
COPY /app/images/ /usr/share/nginx/html/images
EXPOSE 80