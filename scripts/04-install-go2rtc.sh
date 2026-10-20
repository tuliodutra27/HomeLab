#!/bin/bash
set -e

CAM_IP="192.168.1.115"
CAM_PORT="8080"
SERVICE_DIR="$(cd "$(dirname "$0")/../services/go2rtc" && pwd)"

echo "==> Verificando Docker..."
if ! command -v docker &> /dev/null; then
  echo "ERRO: Docker não encontrado. Execute primeiro: bash scripts/02-install-docker.sh"
  exit 1
fi

echo "==> Verificando se o celular responde em $CAM_IP:$CAM_PORT..."
if timeout 5 bash -c "echo > /dev/tcp/$CAM_IP/$CAM_PORT" 2>/dev/null; then
  echo "    OK, IP Webcam encontrado."
else
  echo "    AVISO: $CAM_IP:$CAM_PORT não respondeu. Confira se o servidor do IP Webcam está iniciado."
  echo "    A instalação continua; o stream funciona assim que o celular estiver online."
fi

cd "$SERVICE_DIR"

if [ ! -f .env ]; then
  echo "==> Criando .env..."
  read -rp  "    Usuário do painel go2rtc [admin]: " GO2RTC_USER
  read -rsp "    Senha do painel go2rtc: " GO2RTC_PASS; echo
  read -rp  "    Usuário do IP Webcam: " CAM_USER
  if [ -z "$CAM_USER" ]; then
    echo "ERRO: configure Login/Senha no app IP Webcam (Configurações locais) e rode de novo."
    exit 1
  fi
  read -rsp "    Senha do IP Webcam: " CAM_PASS; echo
  cat > .env <<EOF
GO2RTC_USER=${GO2RTC_USER:-admin}
GO2RTC_PASS=$GO2RTC_PASS
CAM_USER=$CAM_USER
CAM_PASS=$CAM_PASS
EOF
  chmod 600 .env
else
  echo "==> .env já existe, mantendo."
fi

echo "==> Subindo go2rtc..."
docker compose pull
docker compose up -d

TS_IP="$(tailscale ip -4 2>/dev/null || echo '<TAILSCALE-IP>')"

echo ""
echo "==> go2rtc instalado com sucesso!"
echo "    Painel:  http://$TS_IP:1984"
echo "    Câmera:  http://$TS_IP:1984/stream.html?src=s21fe"
echo "    RTSP:    rtsp://$TS_IP:8554/s21fe"
echo ""
echo "    Logs: docker logs -f go2rtc"
