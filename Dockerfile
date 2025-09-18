# Base image
FROM node:18-alpine

# Set working directory
WORKDIR /app

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
