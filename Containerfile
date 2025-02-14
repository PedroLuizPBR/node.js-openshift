# Use RHEL8 UBI node 22 image as base
FROM registry.access.redhat.com/ubi9/nodejs-22:latest

# Set Name application
LABEL name="nodejs" \
      io.k8s.display-name="cs3gatway" \
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

# Expose the 3000 port to accept upcomming traffic
EXPOSE 3000

# Execute the start script
CMD ["npm", "start"]
