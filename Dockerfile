# Use Debian-based Node image for compatibility
FROM node:18-slim

# Set working directory
WORKDIR /app

# Copy only package files first
COPY package*.json ./

# Install dependencies inside container
RUN npm install --legacy-peer-deps

# Copy the rest of the project
COPY . .

# Build Strapi project
RUN npm run build

# Expose Strapi port
EXPOSE 1337

# Start the app
CMD ["npm", "run", "start"]
