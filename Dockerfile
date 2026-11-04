# Stage 1: use Node.js to build the Vue application.
FROM node:24-alpine AS build-stage

# Set the working folder inside the build stage.
WORKDIR /app

# Copy the dependency list and lockfile before the application code.
COPY package.json package-lock.json ./

# Install all packages needed to build the frontend.
RUN npm ci

# Copy the frontend source files, respecting .dockerignore.
COPY . .

# Accept API addresses as build inputs, with defaults for local Docker.
ARG VUE_APP_ORDER_SERVICE_URL=http://localhost:3000
ARG VUE_APP_PRODUCT_SERVICE_URL=http://localhost:3030

# Compile the Vue source into static files in /app/dist.
RUN npm run build

# Stage 2: use Nginx to serve the compiled website.
FROM nginx:alpine

# Copy the website files into Nginx's default website folder.
COPY --from=build-stage /app/dist /usr/share/nginx/html

# Document Nginx's HTTP port inside the container.
EXPOSE 80
