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

# Copy the packages from remote directory to container work directory
COPY --chown=1001:1001 package.json ./

# Install all dependacies using npm
RUN npm install

# Copy the application to container
COPY --chown=1001:1001 . /usr/src/app

# Expose the 3001 port to accept upcomming traffic
EXPOSE 3001

# Switch to root user to install system packages
USER root

# Install GCC 12, OpenSSL, Make, CMake, GMake, Node-API, node-gyp, node-red, node-red-dashboard, node-red-nodes, and node-red-ui-nodes
RUN dnf install -y gcc gcc-c++ \
    && dnf install -y openssl-devel \
    && dnf install -y make \
    && dnf install -y cmake \
    && npm install node-addon-api \
    && npm install -g node-gyp \
    && npm install -g node-red \
    && npm install -g node-red-dashboard \
    && npm install -g node-red-nodes \
    && npm install -g node-red-admin 

# Execute the start script
CMD ["npm", "start"]
