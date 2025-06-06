# 🏗️ STAGE 1: Build Stage (The Workshop)
# WHY: We use this stage to install dependencies and prepare everything
FROM node:24-alpine AS builder

# WHY: Alpine is tiny (5MB vs 900MB) but has everything Node.js needs
WORKDIR /app

# 📦 Copy package files FIRST
# WHY: If these don't change, Docker can cache this layer
COPY /package*.json ./

# 🔧 Install dependencies
# WHY: --only=production excludes dev dependencies
# WHY: npm ci is faster and more reliable than npm install
# WHY: We clean cache to reduce size
RUN npm ci --only=production && \
    npm cache clean --force

# 🏃‍♂️ STAGE 2: Production Stage (The Clean Room)
# WHY: We start fresh with a clean image, copying only what we need
FROM node:24-alpine

# 👤 Create non-root user for security
# WHY: Running as root is dangerous - if someone hacks your app, they get root access
RUN addgroup -g 1001 -S nodejs && \
    adduser -S appuser -u 1001 -G nodejs

WORKDIR /app

# 📋 Copy dependencies from builder stage
# WHY: We get clean dependencies without build artifacts
COPY --from=builder /app/node_modules ./node_modules

# 📁 Copy application code
# WHY: We copy this LAST so code changes don't invalidate dependency cache
COPY . .

# 🔒 Set proper ownership and permissions
# WHY: Our app files should belong to our app user, not root
RUN chown -R appuser:nodejs /app

# 🩺 Add health check
# WHY: Docker/Kubernetes can monitor if your app is healthy
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD node -e "require('http').get('http://localhost:3000/health', (res) => { process.exit(res.statusCode === 200 ? 0 : 1) })" || exit 1

# 👤 Switch to non-root user
# WHY: All operations from now on happen as regular user, not root
USER appuser

EXPOSE 3000

# 🚀 Start the application
# WHY: We use 'node' directly instead of 'npm start' for better signal handling
CMD ["node", "server.js"]
