# Use RHEL9 UBI node 22 image as base
FROM registry.access.redhat.com/ubi9/nodejs-22:latest

# Set application metadata
LABEL name="nodejs" \
      io.k8s.display-name="cs3gateway" \
      io.openshift.display-name="cs3gateway"

# Set environment variable to development mode
ENV NODE_ENV=development

# Define the working directory inside the container
WORKDIR /usr/src/app

# Copy package files first for better caching
COPY --chown=1001:0 package.json ./

# Install only production dependencies
RUN npm install --only=production

# Copy application files to the container
COPY --chown=1001:0 . .

# Expose port 3001 for incoming traffic
EXPOSE 3001

# Switch to root user to install required system dependencies
USER root
RUN dnf install -y gcc gcc-c++ \
    openssl-devel make cmake git python3 ca-certificates json-c net-tools \
    && npm install -g node-gyp node-red node-red-dashboard node-red-nodes node-red-admin \
    && dnf clean all \
    && rm -rf /var/cache/dnf

# Copy the start script to the container
COPY --chown=1001:1001 start.sh /usr/src/app/start.sh

# Ensure execution permissions
RUN chmod +x /usr/src/app/start.sh

# Switch back to a non-root user for security and OpenShift compatibility
USER 1001

# Use the script as the default command
CMD ["sh", "-c", "/usr/src/app/start.sh"]
