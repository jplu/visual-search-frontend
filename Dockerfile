# build stage
FROM node:10.15.3-alpine as build-stage
WORKDIR /app
COPY . ./
RUN apk update && apk upgrade && \
    apk add --no-cache bash git openssh
RUN npm install
RUN npm run build

# production stage
FROM nginx:1.15.12-alpine as production-stage
COPY --from=build-stage /app/dist /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
