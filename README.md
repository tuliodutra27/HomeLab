# HomeLab

Homelab pessoal rodando em um Lenovo IdeaPad 320, com acesso externo e serviços auto-hospedados.

## Hardware

| Componente | Especificação |
|------------|---------------|
| Modelo     | Lenovo IdeaPad 320 |
| CPU        | Intel Core i5-7200U (2 cores / 4 threads, 2.5GHz base) |
| RAM        | 8 GB |
| Armazenamento | 300 GB HDD |
| GPU        | NVIDIA (dedicada) |
| SO         | Ubuntu Server 24.04 LTS |

## Objetivos

- [x] Configurar servidor para rodar com a tela fechada
- [x] Instalar Tailscale para acesso remoto seguro
- [x] Instalar Docker
- [x] Instalar CasaOS como painel de gestão
- [x] Configurar Nginx Proxy Manager para URLs dos apps
- [x] Rodar apps Python como containers
- [ ] Monitoramento do servidor (uptime, recursos)
- [ ] Backups automáticos

## Stack

| Camada | Tecnologia |
|--------|-----------|
| Acesso remoto | Tailscale (VPN mesh, funciona com CGNAT) |
| DNS interno | AdGuard Home |
| Containers | Docker + Docker Compose |
| Painel | CasaOS (porta 8888) |
| Reverse proxy | Nginx Proxy Manager (porta 80) |
| Apps | Python (FastAPI, Flask, etc.) |

## Serviços ativos

| URL | Serviço | Porta |
|-----|---------|-------|
| `homelab.io` | CasaOS | 8888 |
| `uniasselvi-sjb.homelab.io` | Student Enrollment Tracker | 5000 |
| `nextcloud.homelab.io` | Nextcloud | 10081 |
| `netdata.homelab.io` | Netdata | 19999 |
| `ihatemoney.homelab.io` | IHateMoney | 8001 |
| `adguard.homelab.io` | AdGuard Home | 3001 |

> Todos os domínios resolvem via AdGuard Home com rewrite `*.homelab.io` e `homelab.io` → IP Tailscale do servidor.

## Ordem de instalação

```
1. bash scripts/01-install-tailscale.sh
2. bash scripts/02-install-docker.sh
3. bash scripts/03-install-casaos.sh
4. Instalar Nginx Proxy Manager via docker compose (services/nginx-proxy-manager/)
5. Instalar AdGuard Home via docker compose (services/adguard-home/)
```

## Estrutura do Repositório

```
HomeLab/
├── docs/
│   ├── 01-tailscale.md           # Acesso remoto
│   ├── 02-docker.md              # Instalação do Docker
│   ├── 03-casaos.md              # Painel CasaOS
│   ├── 04-nginx-proxy-manager.md # Reverse proxy e URLs
│   └── 05-python-app.md          # Deploy de apps Python
├── scripts/
│   ├── 01-install-tailscale.sh
│   ├── 02-install-docker.sh
│   └── 03-install-casaos.sh
└── services/
    └── nginx-proxy-manager/
        └── docker-compose.yml
```

## Configurações Iniciais

### Manter laptop funcionando com a tela fechada

Editar `/etc/systemd/logind.conf`:

```
HandleLidSwitch=ignore
HandleLidSwitchExternalPower=ignore
```

Aplicar:

```bash
sudo sed -i 's/#HandleLidSwitch=suspend/HandleLidSwitch=ignore/' /etc/systemd/logind.conf
sudo sed -i 's/#HandleLidSwitchExternalPower=suspend/HandleLidSwitchExternalPower=ignore/' /etc/systemd/logind.conf
sudo systemctl restart systemd-logind
```
