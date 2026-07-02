# Stage 1: Build the React app
FROM node:lts AS builder
WORKDIR /app
COPY package.json package-lock.json* ./
RUN npm ci # Use ci for strict production install
COPY . .
RUN npm run build # Builds the Vite app to /app/dist

# Stage 2: Serve with Nginx
FROM nginx:alpine
# Copy built files from Stage 1
COPY --from=builder /app/dist /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]