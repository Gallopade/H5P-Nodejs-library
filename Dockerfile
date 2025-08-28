# Use Node 20 slim (lighter image, supported by monorepo)
FROM node:20-slim

# Set working dir
WORKDIR /usr/src/app

# Ensure system deps for native modules (like @node-rs/crc32) are available
RUN apt-get update && apt-get install -y \
    python3 make g++ \
    && rm -rf /var/lib/apt/lists/*

# Create a writable npm cache and node_modules folder
RUN mkdir -p /home/node/.npm /usr/src/app/node_modules \
    && chown -R node:node /home/node/.npm /usr/src/app
ENV NPM_CONFIG_CACHE=/home/node/.npm


# Copy everything (monorepo requires all packages for workspaces)
COPY --chown=node:node . .

# Switch to non-root user
USER node

# Install dependencies (don’t delete package-lock.json)
RUN npm install --legacy-peer-deps --build-from-source

# Rebuild native modules (crc32, etc.)
RUN npm rebuild @node-rs/crc32 || echo "crc32 rebuild skipped"

# Build the packages (monorepo build step)
RUN npm run build

# Expose the app port
EXPOSE 8765

# Run the example server
CMD ["node", "packages/h5p-examples/build/express.js"]
