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
- [ ] Configurar acesso externo (domínio + túnel ou port forward)
- [ ] Subir serviços via Docker/Docker Compose
- [ ] Monitoramento do servidor (uptime, recursos)
- [ ] Backups automáticos

## Estrutura do Repositório

```
HomeLab/
├── docs/          # Documentação e guias de configuração
├── scripts/       # Scripts de setup e automação
└── services/      # Docker Compose e configurações dos serviços
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
