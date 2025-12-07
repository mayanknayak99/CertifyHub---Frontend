# ---------- Build stage ----------
FROM node:18-alpine AS build

WORKDIR /app

# Copy dependency files
COPY package*.json ./

# Install deps (ignore peer dependency conflicts)
RUN npm ci --legacy-peer-deps

# Copy rest of the code
COPY . .

# Build the production bundle
RUN npm run build

# ---------- Run stage ----------
FROM nginx:alpine

# Copy built files to nginx web root (NOTE: build, not dist)
COPY --from=build /app/build /usr/share/nginx/html

# SPA routing config
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
