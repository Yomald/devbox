#!/usr/bin/env bash
set -euo pipefail

LSP_HOME="${HOME}/.lsp"
JDTLS_DIR="${LSP_HOME}/jdtls_dir"

mkdir -p "${LSP_HOME}" "${LSP_HOME}/java" "${JDTLS_DIR}"

# Go language server
go install golang.org/x/tools/gopls@latest
ln -sf "$(go env GOPATH)/bin/gopls" "${LSP_HOME}/gopls"

# Python language servers
python3 -m pip install --user --upgrade ruff ty

ln -sf "${HOME}/.local/bin/ruff" "${LSP_HOME}/ruff"
ln -sf "${HOME}/.local/bin/ty" "${LSP_HOME}/ty"

# TypeScript language server
npm install --prefix "${LSP_HOME}/typescript-language-server_dir" \
    typescript \
    typescript-language-server

ln -sf \
    "${LSP_HOME}/typescript-language-server_dir/node_modules/.bin/typescript-language-server" \
    "${LSP_HOME}/typescript-language-server"

# Eclipse JDT Language Server
JDTLS_URL="https://www.eclipse.org/downloads/download.php?file=/jdtls/milestones/1.61.0/jdt-language-server-1.61.0-202609031315.tar.gz"

curl -fL "${JDTLS_URL}" |
    tar -xzf - \
    -C "${JDTLS_DIR}"

ln -s "${JDTLS_DIR}/bin/jdtls" "${LSP_HOME}/jdtls"

# Lombok
curl -fL \
    -o "${LSP_HOME}/java/lombok.jar" \
    https://projectlombok.org/downloads/lombok.jar

chmod 0644 "${LSP_HOME}/java/lombok.jar"
