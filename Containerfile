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
    perl patch diffutils gcc gcc-c++ gzip unzip libaio openssl-devel make cmake git python3 ca-certificates json-c net-tools \
    numactl-libs libxcrypt-compat file \
    && npm install -g node-gyp node-red node-red-dashboard node-red-nodes node-red-admin \
    && dnf clean all \
    && rm -rf /var/cache/dnf

RUN curl -O https://mirror.stream.centos.org/9-stream/AppStream/ppc64le/os/Packages/ksh-1.0.6-4.el9.ppc64le.rpm && \
    rpm -ivh ksh-1.0.6-4.el9.ppc64le.rpm && \
    rm -f ksh-1.0.6-4.el9.ppc64le.rpm

#RUN ln -sf /usr/bin/ksh /bin/ksh && ln -sf /usr/bin/ksh /usr/bin/ksh93

# Copy the start script to the container
COPY --chown=1001:1001 nodered.sh /usr/src/app/nodered.sh

# Ensure execution permissions
RUN chmod +x /usr/src/app/nodered.sh

# IBM DB2 Client Download URL
ENV DB2_CLIENT_URL="https://ak-delivery04-mul.dhe.ibm.com/sdfdl/v2/sar/CM/IM/0bsyv/0/Xa.2/Xb.jusyLTSp44S048NdUVBNUNtuiMD4K1EIKm-xGyxJHRz_nbhCW4ijzDxaW1s/Xc.CM/IM/0bsyv/0/v11.5.9_linuxppc64le_rtcl.tar.gz/Xd./Xf.LPR.D1vk/Xg.13239087/Xi.habanero/XY.habanero/XZ.0aAz4z5ZEEEpWE2mrcPjK1HPGhtjmG7_/v11.5.9_linuxppc64le_rtcl.tar.gz"

# Download and Install DB2 Client
RUN curl -o /tmp/db2client.tar.gz "$DB2_CLIENT_URL" \
    && cd /tmp \
    && tar -xvzf db2client.tar.gz \
    && /tmp/rtcl/db2_install -b /opt/ibm/db2/V11.5 -y -L en \
    && rm -rf /tmp/rtcl*

# Ensure proper permissions for DB2 installation logs
# RUN chown -R 1001:root /opt/ibm /opt/ibm/db2

# Environment variables
ENV DB2INSTANCE=db2inst1
ENV DB2HOME=/opt/ibm/db2/V11.5
ENV INSTHOME=/home/db2inst1
ENV PATH=$DB2HOME/bin:$PATH
ENV LD_LIBRARY_PATH=$DB2HOME/lib:$LD_LIBRARY_PATH
ENV LIBPATH=$DB2HOME/lib:$LIBPATH
ENV CLASSPATH=$DB2HOME/java/db2java.zip:$DB2HOME/java/db2jcc.jar:$CLASSPATH
ENV DB2DIR=$DB2HOME
ENV DB2MESSAGE=$DB2DIR/msg/en_US.iso88591
ENV NLSPATH=$DB2MESSAGE/%N
ENV DB2CODEPAGE=1208

# Create instnce DB2
RUN /opt/ibm/db2/V11.5/instance/db2icrt -s client -u default db2inst1

# Switch back to a non-root user for security and OpenShift compatibility
USER 1001

# Use the script as the default command
CMD ["sh", "-c", "/usr/src/app/nodered.sh start"]
