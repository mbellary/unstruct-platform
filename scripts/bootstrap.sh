#!/usr/bin/env bash
set -euo pipefail

# ---- REPOSITORY URLs ----
INGESTION_URL="git@github.com:mbellary/file-loader.git"
PROCESSOR_URL="git@github.com:mbellary/pdf-processor.git"
EXTRACTION_URL="git@github.com:mbellary/text-extractor.git"
EMBEDDINGS_URL="git@github.com:mbellary/text-embedder.git"
SEARCH_URL="git@github.com:mbellary/text-rag.git"
INFRA_URL="git@github.com:mbellary/unstruct-infra-terraform.git"  # TODO

mkdir -p modules

add_or_update() {
  local name="$1" url="$2"
  if [ -d "modules/$name" ]; then
    echo "[update] $name"
    git submodule update --init --recursive --remote "modules/$name"
  else
    echo "[add] $name ← $url"
    git submodule add "$url" "modules/$name"
  fi
}

add_or_update file-loader      "$INGESTION_URL"
add_or_update pdf-processor    "$PROCESSOR_URL"
add_or_update text-extractor   "$EXTRACTION_URL"
add_or_update text-embedder    "$EMBEDDINGS_URL"
add_or_update text-rag         "$SEARCH_URL"
add_or_update infra            "$INFRA_URL"
