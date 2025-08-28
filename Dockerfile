FROM node:18

# Set working dir
WORKDIR /usr/src/app

# Create a writable npm cache directory
RUN mkdir -p /home/node/.npm && chown -R node:node /home/node/.npm
ENV NPM_CONFIG_CACHE=/home/node/.npm

# Copy everything (monorepo requires all packages for workspaces)
COPY --chown=node:node . .

# Switch to non-root user
USER node

# Install dependencies (don't delete lockfile!)
RUN npm install --legacy-peer-deps --build-from-source

# Rebuild native modules (crc32, etc.)
RUN npm rebuild @node-rs/crc32

# Build the packages
RUN npm run build

EXPOSE 8765

CMD ["node", "packages/h5p-examples/build/express.js"]
