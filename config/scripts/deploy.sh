sed -i "s|FIREBASE_TOOLS_SITE_ID|$FIREBASE_TOOLS_SITE_ID|" firebase.json;
firebase deploy --only hosting:"$FIREBASE_TOOLS_SITE_ID" --token "$FIREBASE_TOOLS_TOKEN";
sed -i "s|$FIREBASE_TOOLS_SITE_ID|FIREBASE_TOOLS_SITE_ID|" firebase.json;