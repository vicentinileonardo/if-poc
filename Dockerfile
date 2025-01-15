# Stage 1: Development dependencies & Build
FROM node:20-slim AS builder

# Set working directory
WORKDIR /app

# Copy package files
COPY package*.json ./

# Install all dependencies including devDependencies
RUN npm ci

# Copy source code
COPY . .

# Run tests and build
RUN npm run test && \
    npm run build && \
    npm prune --production

# Stage 2: Production
FROM gcr.io/distroless/nodejs20-debian12

# Set environment variables
ENV NODE_ENV=production \
    PORT=3000

# Set user to non-root
USER nonroot:nonroot

# Set working directory
WORKDIR /app

# Copy built assets from builder
COPY --from=builder --chown=nonroot:nonroot /app/dist ./dist
COPY --from=builder --chown=nonroot:nonroot /app/node_modules ./node_modules
COPY --from=builder --chown=nonroot:nonroot /app/package.json ./package.json

# Expose port
EXPOSE 3000

# Command to run the application
CMD ["dist/main.js"]