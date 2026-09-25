#!/usr/bin/env bash
set -euo pipefail

: "${APP_IMAGE:?Defina a imagem por digest}"
: "${PROD_ENV_FILE:?Defina o caminho absoluto do .env de produção}"
: "${PROD_DATA_DIR:?Defina o caminho absoluto dos dados de produção}"
: "${COMPOSE_PROJECT_NAME:?Defina o projeto Compose existente}"
[[ "$PROD_ENV_FILE" = /* && -r "$PROD_ENV_FILE" ]] || { echo '.env ausente ou sem leitura'; exit 1; }
[[ "$PROD_DATA_DIR" = /* && -d "$PROD_DATA_DIR" ]] || { echo 'Diretório de dados inválido'; exit 1; }
[[ "$APP_IMAGE" =~ ^ghcr.io/[a-z0-9._/-]+@sha256:[a-f0-9]{64}$ ]] || { echo 'Imagem deve usar digest do GHCR'; exit 1; }

cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.."
compose=(docker compose --env-file /dev/null -f compose.production.yml)
docker info >/dev/null
"${compose[@]}" config --quiet

previous=''
containers=$(docker ps -a --format '{{.Names}}')
if [[ $'\n'"$containers"$'\n' == *$'\nanalise-ambiente\n'* ]]; then
  owner=$(docker inspect --format '{{index .Config.Labels "com.docker.compose.project"}}' analise-ambiente)
  [[ "$owner" == "$COMPOSE_PROJECT_NAME" ]] || { echo "Projeto Compose divergente: $owner"; exit 1; }
  previous=$(docker inspect --format '{{.Image}}' analise-ambiente)
fi

# Baixar antes de tocar no container em execução.
"${compose[@]}" pull
if "${compose[@]}" up -d --no-build --wait --wait-timeout 120; then
  echo "Deploy saudável: $APP_IMAGE"
  if [[ -n "${GITHUB_STEP_SUMMARY:-}" ]]; then
    printf 'Deploy saudável: %s\nImagem anterior local: %s\n' "$APP_IMAGE" "$previous" >> "$GITHUB_STEP_SUMMARY"
  fi
else
  echo 'Deploy falhou na atualização ou na verificação de saúde.'
  if [[ -n "$previous" ]]; then
    echo "Restaurando imagem anterior: $previous"
    export APP_IMAGE="$previous"
    if ! "${compose[@]}" up -d --no-build --pull never --wait --wait-timeout 120; then
      echo 'Rollback falhou; intervenção manual necessária.'
    fi
  else
    echo 'Primeiro deploy: não há imagem anterior para restaurar.'
  fi
  exit 1
fi
