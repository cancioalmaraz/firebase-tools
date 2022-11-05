ARG FIREBASE_TOOLS_NGINX_VERSION

FROM nginx:${FIREBASE_TOOLS_NGINX_VERSION}

LABEL org.label-schema.vcs-url="https://github.com/cancioalmaraz/firebase-tools"
LABEL org.opencontainers.image.source="https://github.com/cancioalmaraz/firebase-tools"
LABEL org.opencontainers.image.description="Firebase tools and emulators for development."
LABEL org.label-schema.description="Firebase tools and emulators for development."
LABEL org.opencontainers.image.licenses=MIT

ENV FIREBASE_TOOLS_PATH=/usr/share/firebase-tools
ENV CONFIG_PATH=config

RUN apt update && apt install --no-install-recommends -y \
    openjdk-11-jre \
    curl \
    vim \
    supervisor

# Install Node and Npm
ARG FIREBASE_TOOLS_NODE_VERSION
RUN curl -fsSL https://deb.nodesource.com/setup_${FIREBASE_TOOLS_NODE_VERSION}.x | bash -
RUN apt-get install -y nodejs
RUN npm update npm npx --location=global

# Install firebase
ARG FIREBASE_TOOLS_FIREBASE_VERSION
RUN npm install firebase-tools@${FIREBASE_TOOLS_FIREBASE_VERSION} --location=global
RUN firebase setup:emulators:ui && \
    firebase setup:emulators:firestore && \
    firebase setup:emulators:storage && \
    firebase setup:emulators:database && \
    firebase setup:emulators:pubsub

# Copy default project files
COPY $CONFIG_PATH/project/firebase.json $FIREBASE_TOOLS_PATH/project/firebase.json
COPY $CONFIG_PATH/project/firestore.rules $FIREBASE_TOOLS_PATH/project/firestore.rules
COPY $CONFIG_PATH/project/storage.rules $FIREBASE_TOOLS_PATH/project/storage.rules
COPY $CONFIG_PATH/project/database.rules.json $FIREBASE_TOOLS_PATH/project/database.rules.json

# Scripts
COPY $CONFIG_PATH/scripts/deploy.sh $FIREBASE_TOOLS_PATH/deploy.sh

# Entry Point
COPY docker-entrypoint.sh $FIREBASE_TOOLS_PATH/docker-entrypoint.sh

# Nginx config
COPY $CONFIG_PATH/nginx/default.conf /etc/nginx/conf.d/default.conf

# Setting supervisord
RUN mkdir -p /var/log/supervisor
COPY $CONFIG_PATH/supervisor/supervisord.conf $FIREBASE_TOOLS_PATH/supervisor/supervisord.conf

WORKDIR $FIREBASE_TOOLS_PATH/project/

# Expose default ports
# More info: https://firebase.google.com/docs/emulator-suite/install_and_configure#port_configuration

# Authentication
EXPOSE 9099

# Emulator Suite UI
EXPOSE 4000

# Cloud Functions
EXPOSE 5001

# Eventarc
EXPOSE 9299

# Realtime Database
EXPOSE 9000

# Cloud Firestore
EXPOSE 8080

# Cloud Storage for Firebase
EXPOSE 9199

# Firebase Hosting
EXPOSE 5000

# Pub/Sub
EXPOSE 8085

# Other reserved ports
EXPOSE 4500
EXPOSE 9150
EXPOSE 4400

CMD [ "/usr/bin/supervisord", "-c", "/usr/share/firebase-tools/supervisor/supervisord.conf" ]