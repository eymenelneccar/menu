#!/usr/bin/env bash
set -euo pipefail

# Install Flutter (stable) and build Flutter Web for Netlify
# Netlify build image is Linux-based and supports bash, git, curl, and tar.

# 1) Fetch Flutter SDK (stable)
if [ ! -d "flutter" ]; then
  echo "Cloning Flutter SDK (stable) ..."
  git clone https://github.com/flutter/flutter.git -b stable
else
  echo "Flutter SDK already present, using existing copy."
fi

# 2) Add Flutter to PATH
export PATH="$(pwd)/flutter/bin:$PATH"

# 3) Enable web and fetch deps
flutter --version
flutter config --enable-web
flutter pub get

# 4) Build web (release)
# You can switch renderer to html if you prefer: --web-renderer html
flutter build web --release --web-renderer canvaskit --no-tree-shake-icons

# 5) Ensure output directory exists
ls -la build/web || true

echo "Build finished. Publishing directory: build/web"