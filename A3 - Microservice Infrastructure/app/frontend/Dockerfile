# Build
FROM node:18-alpine AS build
WORKDIR /app
COPY package*.json ./
RUN npm ci --silent
COPY . .
# Vite -> dist / CRA -> build
# Wenn du CRA benutzt, ersetze 'dist' unten durch 'build'
RUN npm run build

# Serve
FROM nginx:alpine
COPY --from=build /app/dist /usr/share/nginx/html
EXPOSE 80
