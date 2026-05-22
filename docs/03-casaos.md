# CasaOS — Painel de Gestão

CasaOS é um painel web leve para gerenciar containers Docker, com app store integrada.

## Pré-requisito

Docker instalado (ver `02-docker.md`).

## Instalação

```bash
curl -fsSL https://get.casaos.io | sudo bash
```

O instalador detecta o Docker automaticamente e sobe o CasaOS.

## Acesso

Após a instalação, acesse pelo IP local do servidor:

```
http://<IP-DO-SERVIDOR>
```

Ou pelo IP do Tailscale:

```
http://<TAILSCALE-IP>
```

Na primeira vez será solicitado criar um usuário administrador.

## Adicionar app personalizado (seus apps Python)

1. No painel, clique em **App Store → Custom Install**
2. Cole o `docker-compose.yml` do seu app
3. Clique em **Install**

O app aparece no painel junto com os demais e pode ser iniciado/parado pela interface.

## Estrutura de dados

CasaOS armazena dados dos apps em `/DATA/AppData/<nome-do-app>`.

## Atualizar CasaOS

```bash
curl -fsSL https://get.casaos.io | sudo bash
```
