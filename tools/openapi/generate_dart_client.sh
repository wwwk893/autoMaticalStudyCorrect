#!/usr/bin/env bash
set -euo pipefail

if [ $# -lt 1 ]; then
  echo "Usage: $0 <openapi-spec-url> [output-dir]" >&2
  exit 1
fi

SPEC_URL="$1"
OUTPUT_DIR="${2:-lib/api/generated}"
GENERATOR_IMAGE="openapitools/openapi-generator-cli:v7.6.0"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
TARGET_DIR="${PROJECT_ROOT}/${OUTPUT_DIR}"
TMP_DIR="$(mktemp -d)"

trap 'rm -rf "${TMP_DIR}"' EXIT

mkdir -p "${TARGET_DIR}"

cat >"${TMP_DIR}/config.yaml" <<YAML
generatorName: dart-dio-next
inputSpec: ${SPEC_URL}
outputDir: ${TARGET_DIR}
globalProperties:
  supportingFiles: true
additionalProperties:
  pubName: auto_matical_api_client
  pubVersion: 0.1.0
  nullableFields: true
  dateLibrary: core
  useEnumExtension: true
  useBuiltValue: false
  useFreezed: false
  useDefaultNulls: true
  serializationLibrary: json_serializable
  ensureUniqueParams: true
YAML

if command -v openapi-generator >/dev/null 2>&1; then
  echo "Using local openapi-generator" >&2
  openapi-generator generate -c "${TMP_DIR}/config.yaml"
else
  echo "Using dockerized openapi-generator (${GENERATOR_IMAGE})" >&2
  docker run --rm \
    -v "${TMP_DIR}:/local" \
    -v "${PROJECT_ROOT}:/app" \
    -w /app \
    "${GENERATOR_IMAGE}" generate -c /local/config.yaml
fi

find "${TARGET_DIR}" -type f -name '*.dart' -exec dart format {} + >/dev/null

cat <<MSG
Dart API client generated in ${TARGET_DIR}
Remember to run: flutter pub get
MSG
