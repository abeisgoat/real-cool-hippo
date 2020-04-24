#!/bin/bash
set -e

# Find and increment the version number.
perl -i -pe 's/^(version:\s+\d+\.\d+\.\d+\+)(\d+)$/$1.($2+1)/e' pubspec.yaml

# Commit and tag this change.
version=`grep 'version: ' pubspec.yaml | sed 's/version: //'`
git commit -m "Bump version to $version" pubspec.yaml
git tag $version

bash ./scripts/version.sh
git push
dart2native lib/cli.dart -o cloud_run/cli.exe
cd cloud_run
gcloud builds submit --tag gcr.io/real-cool-hippo/uppo_app
gcloud run deploy uppoapp --image gcr.io/real-cool-hippo/uppo_app --platform managed --region us-central1 --allow-unauthenticated
cd ..
flutter build web
npx firebase deploy -m $version
