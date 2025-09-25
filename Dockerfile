# Base image
FROM node:18-alpine

# Set working directory
WORKDIR /app

# Inject required secrets
ENV API_TOKEN_SALT="j4rqpdb/U8JdU+aubTSBmQ=="
ENV ADMIN_JWT_SECRET="rGNuU8jxCYxmVxQrTcPPFrNg7ue/1L4mNc8wzVXEyiQ="
ENV TRANSFER_TOKEN_SALT="RqkOPXvmnN+3ONyuc78XsxetlLSsMilqi93HA1U/GHE="
ENV ENCRYPTION_KEY="joKNsWCuXj0DgjRfSm6TCjGQp8vCnIylKK4k9g97x5Q="

# Copy package files and install dependencies
COPY package*.json ./
RUN npm install

# Copy the rest of the app
COPY . .

# Build the admin panel
RUN npm run build

# Expose port
EXPOSE 1337

# Start Strapi in production mode
CMD ["npm", "start"]