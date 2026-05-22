#!/bin/bash
set -e

echo "==> Verificando Docker..."
if ! command -v docker &> /dev/null; then
  echo "ERRO: Docker não encontrado. Execute primeiro: bash scripts/02-install-docker.sh"
  exit 1
fi

echo "==> Instalando CasaOS..."
curl -fsSL https://get.casaos.io | sudo bash

echo ""
echo "==> CasaOS instalado com sucesso!"
echo "    Acesse pelo navegador: http://$(hostname -I | awk '{print $1}')"
echo "    Ou pelo IP do Tailscale: http://$(tailscale ip -4 2>/dev/null || echo '<TAILSCALE-IP>')"
