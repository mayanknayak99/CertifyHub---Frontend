# Dockerfile (quick-fix)
FROM node:18-alpine

WORKDIR /app

# copy package files first for cache
COPY package.json package-lock.json ./

# install dependencies while ignoring peer dependency conflicts
RUN npm ci --legacy-peer-deps

# copy the rest of the source
COPY . .

EXPOSE 3000

CMD ["npm", "start"]
