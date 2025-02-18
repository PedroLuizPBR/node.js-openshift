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

# Install all dependencies using npm
RUN npm install

# Copy the application to container
COPY --chown=1001:1001 . /usr/src/app

# Expose the 3001 port to accept upcoming traffic
EXPOSE 3001

# Switch to root user to install system packages
USER root

# Install dependencies, GCC, Node-Red, Git, Python 3, ca-certificates, Application Development for Db2 databases, libssh2-devel, json-c, and jansson-devel
RUN dnf install -y gcc gcc-c++ \
    && dnf install -y openssl-devel \
    && dnf install -y make \
    && dnf install -y cmake \
    && dnf install -y git \
    && dnf install -y python3 \
    && dnf install -y ca-certificates \
    && dnf install -y json-c \
    && dnf install -y jansson-devel \
    && npm install node-addon-api \
    && npm install -g node-gyp \
    && npm install -g node-red \
    && npm install -g node-red-dashboard \
    && npm install -g node-red-nodes \
    && npm install -g node-red-admin

# Download and install Db2 client
RUN curl -L -o db2client.tar.gz "https://ak-delivery04-mul.dhe.ibm.com/sdfdl/v2/sar/CM/IM/0bsyv/0/Xa.2/Xb.jusyLTSp44S048PvKxWqxTpEWIGgvoTzOY6ttfvC9Z3A6ZQIMluo1AIg9Ac/Xc.CM/IM/0bsyv/0/v11.5.9_linuxppc64le_rtcl.tar.gz/Xd./Xf.LPR.D1vk/Xg.13224394/Xi.habanero/XY.habanero/XZ.BH4PgQCdYTeTWhTAcdCO9eKNXDXjEQyZ/v11.5.9_linuxppc64le_rtcl.tar.gz" \
    && tar -xzf v11.5.9_linuxppc64le_rtcl.tar.gz -C /opt/ \
    && rm v11.5.9_linuxppc64le_rtcl.tar.gz \
    && /opt/db2client/install

# Switch back to non-root user
USER 1001

# Execute the start script to run Node-RED on port 3001
CMD ["node-red", "-p", "3001"]
