#!/usr/bin/env bash

set -euo pipefail

usage() {
  cat <<'EOF'
Usage:
  ./scripts/build_apk.sh <flavor> [--mode <debug|profile|release>] [--version <version>] [--output <dir>]

Examples:
  ./scripts/build_apk.sh dev
  ./scripts/build_apk.sh prod --mode release
  ./scripts/build_apk.sh dev --version 0.12.0225.01
  ./scripts/build_apk.sh prod --output ~/Documents/FlowHub_KDS

Output filename format:
  FlowHub_KDS_<version>-<flavor>.apk
EOF
}

if [[ $# -lt 1 ]]; then
  usage
  exit 1
fi

FLAVOR="$1"
shift

MODE="release"
VERSION_OVERRIDE=""
OUTPUT_DIR="${HOME}/Documents/FlowHub_KDS"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --mode)
      MODE="${2:-}"
      shift 2
      ;;
    --version)
      VERSION_OVERRIDE="${2:-}"
      shift 2
      ;;
    --output)
      OUTPUT_DIR="${2:-}"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown argument: $1"
      usage
      exit 1
      ;;
  esac
done

case "$FLAVOR" in
  dev)
    TARGET="lib/main_dev.dart"
    ;;
  prod)
    TARGET="lib/main_prod.dart"
    ;;
  *)
    echo "Invalid flavor: $FLAVOR (allowed: dev|prod)"
    exit 1
    ;;
esac

case "$MODE" in
  debug|profile|release) ;;
  *)
    echo "Invalid mode: $MODE (allowed: debug|profile|release)"
    exit 1
    ;;
esac

if [[ -n "$VERSION_OVERRIDE" ]]; then
  APP_VERSION="$VERSION_OVERRIDE"
else
  if [[ ! -f pubspec.yaml ]]; then
    echo "pubspec.yaml not found. Run script at project root."
    exit 1
  fi

  VERSION_LINE="$(grep -E '^version:' pubspec.yaml | head -n1 | awk '{print $2}')"
  if [[ -z "$VERSION_LINE" ]]; then
    echo "Cannot read version from pubspec.yaml"
    exit 1
  fi

  BUILD_NAME="${VERSION_LINE%%+*}"
  if [[ "$VERSION_LINE" == *"+"* ]]; then
    BUILD_NUMBER_RAW="${VERSION_LINE##*+}"
    if [[ "$BUILD_NUMBER_RAW" =~ ^[0-9]+$ ]]; then
      BUILD_NUMBER="$(printf "%02d" "$BUILD_NUMBER_RAW")"
    else
      BUILD_NUMBER="$BUILD_NUMBER_RAW"
    fi
    APP_VERSION="${BUILD_NAME}.${BUILD_NUMBER}"
  else
    APP_VERSION="$BUILD_NAME"
  fi
fi

if [[ -d ".fvm" ]] && command -v fvm >/dev/null 2>&1; then
  FLUTTER_CMD=(fvm flutter)
else
  FLUTTER_CMD=(flutter)
fi

echo "Building flavor=$FLAVOR mode=$MODE target=$TARGET"
"${FLUTTER_CMD[@]}" build apk -t "$TARGET" --flavor "$FLAVOR" "--$MODE"

SOURCE_APK="build/app/outputs/flutter-apk/app-${FLAVOR}-${MODE}.apk"
if [[ ! -f "$SOURCE_APK" ]]; then
  SOURCE_APK="$(ls -1 build/app/outputs/flutter-apk/app-*"${FLAVOR}"-"${MODE}".apk 2>/dev/null | head -n1 || true)"
fi

if [[ -z "$SOURCE_APK" || ! -f "$SOURCE_APK" ]]; then
  echo "Cannot find built APK for flavor=$FLAVOR mode=$MODE"
  exit 1
fi

mkdir -p "$OUTPUT_DIR"
OUTPUT_FILE="${OUTPUT_DIR}/FlowHub_KDS_${APP_VERSION}-${FLAVOR}.apk"
cp -f "$SOURCE_APK" "$OUTPUT_FILE"

echo "APK exported: $OUTPUT_FILE"
