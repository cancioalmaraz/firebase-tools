firebase use "$FIREBASE_TOOLS_PROJECT_ID" --token "$FIREBASE_TOOLS_TOKEN";
firebase emulators:start --import ./data/export --export-on-exit --token "$FIREBASE_TOOLS_TOKEN";