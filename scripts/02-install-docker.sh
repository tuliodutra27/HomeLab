#!/bin/bash
set -e

echo "==> Atualizando pacotes..."
sudo apt update

echo "==> Instalando dependências..."
sudo apt install -y ca-certificates curl gnupg

echo "==> Adicionando repositório oficial do Docker..."
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
  https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

echo "==> Instalando Docker..."
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

echo "==> Adicionando usuário ao grupo docker..."
sudo usermod -aG docker "$USER"

echo "==> Ativando Docker na inicialização..."
sudo systemctl enable --now docker

echo ""
echo "==> Docker instalado com sucesso!"
docker version
echo ""
echo "ATENÇÃO: Faça logout e login novamente (ou rode 'newgrp docker') para usar Docker sem sudo."
