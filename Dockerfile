ARG FIREBASE_TOOLS_NGINX_VERSION

FROM nginx:${FIREBASE_TOOLS_NGINX_VERSION}

LABEL org.opencontainers.image.source=https://github.com/cancioalmaraz/firebase-tools
LABEL org.opencontainers.image.description="Firebase tools and emulators for development."
LABEL org.opencontainers.image.licenses=MIT

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
COPY config/project/firebase.json /usr/share/firebase-tools/project/firebase.json
COPY config/project/firestore.rules /usr/share/firebase-tools/project/firestore.rules
COPY config/project/storage.rules /usr/share/firebase-tools/project/storage.rules
COPY config/project/database.rules.json /usr/share/firebase-tools/project/database.rules.json

# Scripts
COPY config/scripts/deploy.sh /usr/share/firebase-tools/deploy.sh

# Entry Point
COPY docker-entrypoint.sh /usr/share/firebase-tools/docker-entrypoint.sh

# Nginx config
COPY config/nginx/default.conf /etc/nginx/conf.d/default.conf

# Setting supervisord
RUN mkdir -p /var/log/supervisor
COPY config/supervisor/supervisord.conf /usr/share/firebase-tools/supervisor/supervisord.conf

WORKDIR /usr/share/firebase-tools/project/

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