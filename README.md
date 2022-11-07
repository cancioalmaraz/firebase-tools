# Firebase tools

Firebase tools and emulators for development.

This image contains the firebase cli and exposes the firebase emulators, it also helps with deploys using a deploy.sh script

## Using image with docker compose

Example file

```yml
version: '3.9'

services:
  firebase-tools:
    container_name: firebase_tools
    image: cancioalmaraz/firebase-tools:11.16.0-node18
    ports:
      - "127.0.0.1:${FIREBASE_TOOLS_AUTH_PORT:-9099}:9099"
      - "127.0.0.1:${FIREBASE_TOOLS_UI_PORT:-4000}:4000"
      - "127.0.0.1:${FIREBASE_TOOLS_FIRESTORE_PORT:-8080}:8080"
      - "127.0.0.1:${FIREBASE_TOOLS_STORAGE_PORT:-9199}:9199"
      - "127.0.0.1:${FIREBASE_TOOLS_HOSTING_PORT:-5000}:5000"
      - "127.0.0.1:${FIREBASE_TOOLS_DATABASE_PORT:-9000}:9000"
      - "127.0.0.1:${FIREBASE_TOOLS_PUBSUB_PORT:-8085}:8085"
      - "127.0.0.1:4500:4500"
      - "127.0.0.1:9150:9150"
      - "127.0.0.1:4400:4401"
    environment:
      - FIREBASE_TOOLS_PROJECT_ID=${FIREBASE_TOOLS_PROJECT_ID}
      - FIREBASE_TOOLS_TOKEN=${FIREBASE_TOOLS_TOKEN}
    volumes:
      - firebase_tools_data:/usr/share/firebase-tools/project/data/

volumes:
  firebase_tools_data:
```

Where:
- FIREBASE_TOOLS_PROJECT_ID: (Mandatory) Firebase project ID
- FIREBASE_TOOLS_TOKEN: (Mandatory) To get this token [click here](https://firebase.google.com/docs/cli#cli-ci-systems)

## Using for deployments

- Share your public folder with the container and set the environment variable FIREBASE_TOOLS_SITE_ID

  ```yml
  version: '3.9'

  services:
    firebase-tools:
      container_name: firebase_tools
      image: cancioalmaraz/firebase-tools:11.16.0-node18
      ...
      environment:
        - FIREBASE_TOOLS_PROJECT_ID=${FIREBASE_TOOLS_PROJECT_ID}
        - FIREBASE_TOOLS_TOKEN=${FIREBASE_TOOLS_TOKEN}
        - FIREBASE_TOOLS_SITE_ID=${FIREBASE_TOOLS_SITE_ID:-site-id}
      volumes:
        - ./public/:/usr/share/firebase-tools/project/public/
        ...
  ```

- Up firebase-tools container

  ```shell
  docker compose up firebase-tools -d
  ```

- Enter into firebase-tools container

  ```shell
  docker compose exec firebase-tools bash
  ```

- Execute deploy

  ```shell
  /bin/bash /usr/share/firebase-tools/deploy.sh
  ```

## Using your files

Share your files with container

```yml
version: '3.9'

services:
  firebase-tools:
    container_name: firebase_tools
    image: cancioalmaraz/firebase-tools:11.16.0-node18
    ...
    volumes:
      - ./path/to/your/firebase.json:/usr/share/firebase-tools/project/firebase.json
      - ./path/to/your/firestore.rules:/usr/share/firebase-tools/project/firestore.rules
      - ./path/to/your/storage.rules:/usr/share/firebase-tools/project/storage.rules
      - ./path/to/your/database.rules.json:/usr/share/firebase-tools/project/database.rules.json
      ...
```

### Warning

The firebase.json file must expose the Emulator Suite UI on port 4001.

```json
{
  ...
  "emulators": {
    ...
    "ui": {
      "enabled": true,
      "port": 4001      // Warning: Expose Emulator Suite UI on this port (4001)
    },
    "singleProjectMode": true
  }
}
```

## Exposed ports

| Port             | Use                    |
| ---------------- | ---------------------- |
| 9099             | Authentication         |
| 4000             | Emulator Suite UI      |
| 5001             | Cloud functions        |
| 9299             | Eventarc               |
| 9000             | Realtime database      |
| 8080             | Cloud firestore        |
| 9199             | Cloud storage          |
| 5000             | Firebase Hosting       |
| 8085             | Pub/Sub                |
| 4500, 9150, 4401 | Another reserved ports |

## Examples

- [Basic example with docker compose](https://github.com/cancioalmaraz/firebase-tools/tree/main/examples/basic-example-with-docker-compose)
