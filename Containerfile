# Use RHEL9 UBI node 22 image as base
FROM registry.access.redhat.com/ubi9/nodejs-22:latest

# Set Name application
LABEL name="nodejs" \
      io.k8s.display-name="cs3gateway" \
      io.openshifit.display-name="cs3gateway"

# Set environment variable as development
ENV NODE_ENV=development

# Defining work directory
WORKDIR /usr/src/app

# Switch to root user to install system packages
USER root

# Install GCC 12, OpenSSL, Make, CMake, GMake, Node-API, node-gyp, node-red, node-red-dashboard, node-red-nodes, and node-red-ui-nodes
RUN dnf install -y gcc gcc-c++ \
    && dnf install -y openssl-devel \
    && dnf install -y make \
    && dnf install -y cmake \
    && dnf install -y gmake \
    && npm install node-addon-api \
    && npm install -g node-gyp \
    && npm install -g node-red \
    && npm install -g node-red-dashboard \
    && npm install -g node-red-nodes \
    && npm install -g node-red-ui-nodes

# Switch back to non-root user
USER 1001

# Copy the packages from remote directory to container work directory
COPY --chown=1001:1001 package.json ./

# Install all dependencies using npm
RUN npm install

# Copy the application to container
COPY --chown=1001:1001 . /usr/src/app

# Copy the public directory to container
COPY --chown=1001:1001 public /usr/src/app/public

# Expose the 3000 port to accept upcoming traffic
EXPOSE 3000

# Execute the start script
CMD ["npm", "start"]
