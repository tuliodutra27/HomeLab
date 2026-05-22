#!/bin/bash
set -e

echo "==> Instalando Tailscale..."
curl -fsSL https://tailscale.com/install.sh | sh

echo "==> Ativando serviço na inicialização..."
sudo systemctl enable --now tailscaled

echo "==> Autenticando no Tailscale..."
echo "    Siga o link que aparecer abaixo para autenticar:"
sudo tailscale up

echo ""
echo "==> Tailscale instalado com sucesso!"
echo "    IP no tailnet: $(tailscale ip -4)"
