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

- [ ] Configurar servidor para rodar com a tela fechada
- [ ] Instalar Tailscale para acesso remoto seguro
- [ ] Instalar Docker
- [ ] Instalar CasaOS como painel de gestão
- [ ] Configurar Nginx Proxy Manager para URLs dos apps
- [ ] Rodar apps Python como containers
- [ ] Monitoramento do servidor (uptime, recursos)
- [ ] Backups automáticos

## Stack

| Camada | Tecnologia |
|--------|-----------|
| Acesso remoto | Tailscale (VPN mesh, funciona com CGNAT) |
| Containers | Docker + Docker Compose |
| Painel | CasaOS |
| Reverse proxy | Nginx Proxy Manager |
| Apps | Python (FastAPI, Flask, etc.) |

## Ordem de instalação

```
1. bash scripts/01-install-tailscale.sh
2. bash scripts/02-install-docker.sh
3. bash scripts/03-install-casaos.sh
4. Instalar Nginx Proxy Manager via App Store do CasaOS
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
