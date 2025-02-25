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

RUN dnf install -y \
    diffutils gcc gcc-c++ gzip unzip libaio openssl-devel make cmake git python3 ca-certificates json-c net-tools \
    numactl-libs libxcrypt-compat file \
    && npm install -g node-gyp node-red node-red-dashboard node-red-nodes node-red-admin \
    && dnf clean all \
    && rm -rf /var/cache/dnf

RUN curl -O https://mirror.stream.centos.org/9-stream/AppStream/ppc64le/os/Packages/ksh-1.0.6-4.el9.ppc64le.rpm && \
    rpm -ivh ksh-1.0.6-4.el9.ppc64le.rpm && \
    ln -sf /usr/bin/ksh /bin/ksh && \
    rm -f ksh-1.0.6-4.el9.ppc64le.rpm

# Copy the start script to the container
COPY --chown=1001:1001 nodered.sh /usr/src/app/nodered.sh

# Ensure execution permissions
RUN chmod +x /usr/src/app/nodered.sh

# IBM DB2 Client Download URL
ENV DB2_CLIENT_URL="https://ak-delivery04-mul.dhe.ibm.com/sdfdl/v2/sar/CM/IM/0csmj/0/Xa.2/Xb.jusyLTSp44S0Bsg8sTtAzvsTdD-Rrkf3LGGf8DXOtRbhR0ZFqK7Vv-NmePE/Xc.CM/IM/0csmj/0/special_52441_v11.5.9_linuxppc64le_client.tar.gz/Xd./Xf.LPR.D1vk/Xg.13234695/Xi.habanero/XY.habanero/XZ.50W1898O9NTjrXB6_Z3zeVeyxh0kU4fw/special_52441_v11.5.9_linuxppc64le_client.tar.gz"

# Copy the start script to the container
COPY --chown=1001:1001 db2Resp.rsp /tmp/db2Resp.rsp

# Create installation directory and set permissions
RUN mkdir -p /opt/ibm/db2 && chown -R 1001:1001 /opt/ibm/db2

# Ensure execution permissions
RUN chmod +rw /tmp/db2Resp.rsp

# Download and Install DB2 Client
RUN curl -o /tmp/db2client.tar.gz "$DB2_CLIENT_URL" \
    && cd /tmp \
    && tar -xvzf db2client.tar.gz \
    && ./client/db2_install -b /opt/ibm/db2/V11.5 -r /tmp/db2Resp.rsp \
    && rm -rf /tmp/client*

# Ensure proper permissions for DB2 installation logs
RUN chown -R 1001:1001 /usr/src/app

# Environment variables
ENV DB2_HOME=/opt/ibm/db2/V11.5
ENV PATH="$DB2_HOME/bin:$PATH"
ENV LD_LIBRARY_PATH="$DB2_HOME/lib"

# Switch back to a non-root user for security and OpenShift compatibility
USER 1001

# Use the script as the default command
CMD ["sh", "-c", "/usr/src/app/nodered.sh start"]
