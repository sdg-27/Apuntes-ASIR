#!/usr/bin/env bash
GITHUB_USER="sdg-27"
REPO_NAME="Apuntes-ASIR"
BRANCH="main"

# Cargar token desde archivo externo
source /home/sergio/.config/Apuntes-ASIR.env

# Mensaje de commit automático con fecha y hora
COMMIT_MSG="Auto-commit: $(date '+%Y-%m-%d %H:%M')"

# ────────────────────────────────────────────────────────────
set -euo pipefail

log()  { echo "[INFO]  $*"; }
ok()   { echo "[OK]    $*"; }
warn() { echo "[WARN]  $*"; }
err()  { echo "[ERROR] $*" >&2; exit 1; }

[[ -z "$GITHUB_TOKEN" ]] && err "El token no puede estar vacío."

command -v git >/dev/null 2>&1 || err "git no está instalado."

REPO_DIR="/home/sergio/Escritorio/Apuntes-ASIR"
cd "$REPO_DIR" || err "No se encontró el directorio $REPO_DIR"

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  log "Inicializando repositorio git..."
  git init
  git remote add origin "https://${GITHUB_USER}:${GITHUB_TOKEN}@github.com/${GITHUB_USER}/${REPO_NAME}.git"
  ok "Repositorio inicializado."
fi

REMOTE_URL="https://${GITHUB_USER}:${GITHUB_TOKEN}@github.com/${GITHUB_USER}/${REPO_NAME}.git"

if git remote get-url origin >/dev/null 2>&1; then
  git remote set-url origin "$REMOTE_URL"
else
  git remote add origin "$REMOTE_URL"
fi

if git diff --quiet && git diff --cached --quiet && \
   [[ -z "$(git ls-files --others --exclude-standard)" ]]; then
  warn "No hay cambios nuevos. Nada que subir."
  exit 0
fi

log "Añadiendo todos los archivos..."
git add -A

log "Creando commit: \"${COMMIT_MSG}\""
git commit -m "$COMMIT_MSG"

log "Subiendo a origin/${BRANCH}..."
git push -u origin "$BRANCH"

ok "¡Repositorio actualizado en GitHub!"
