# Publicar `uniasselvi-sjb` via Cloudflare Tunnel + is-a.dev

> Deploy gratuito de aplicação Flask + Docker rodando em homelab atrás de CGNAT, com domínio público estável, HTTPS automático e backup do banco SQLite.

---

## Sumário

- [Visão geral da arquitetura](#visão-geral-da-arquitetura)
- [Pré-requisitos](#pré-requisitos)
- [Etapa 1 — Criar o túnel no painel da Cloudflare](#etapa-1--criar-o-túnel-no-painel-da-cloudflare)
- [Etapa 2 — Subir o cloudflared no homelab](#etapa-2--subir-o-cloudflared-no-homelab)
- [Etapa 3 — Pedir o subdomínio `uniasselvi-sjb.is-a.dev`](#etapa-3--pedir-o-subdomínio-uniasselvi-sjbis-adev)
- [Etapa 4 — Conectar o domínio ao túnel](#etapa-4--conectar-o-domínio-ao-túnel-quando-pr-for-aprovado)
- [Etapa 5 — Backup do banco SQLite](#etapa-5--backup-do-banco-sqlite)
- [Etapa 6 — Segurança extra com Cloudflare Access](#etapa-6--segurança-extra-com-cloudflare-access)
- [Checklist final](#checklist-final)
- [Ponto crítico de troubleshooting](#ponto-crítico-de-troubleshooting)

---

## Visão geral da arquitetura

```
[Usuário do polo] → uniasselvi-sjb.is-a.dev → Cloudflare Edge
                                                    ↓
                                              [Túnel reverso]
                                                    ↓
                                            [cloudflared no notebook]
                                                    ↓
                                            [docker compose: Flask:5000]
                                                    ↓
                                              [SQLite + uploads]
```

A grande sacada: o is-a.dev usa Cloudflare como DNS deles, então você **não troca nameservers**. Você só pede um `CNAME` no PR apontando pro hostname do seu túnel Cloudflare. Isso é mais simples do que o caminho tradicional.

---

## Pré-requisitos

- Conta gratuita na Cloudflare ([dash.cloudflare.com](https://dash.cloudflare.com))
- Conta no GitHub
- Notebook do homelab com Docker e a app rodando
- ~30 minutos de paciência

---

## Etapa 1 — Criar o túnel no painel da Cloudflare

> **Nota:** Em 2026 a Cloudflare migrou pra **remotely-managed tunnels** — toda config fica no dashboard, o `cloudflared` local só precisa de um token. Não precisa mais editar `config.yml` manualmente.

### 1.1. Acessar o Zero Trust dashboard

1. Logue em [one.dash.cloudflare.com](https://one.dash.cloudflare.com)
2. Na primeira vez, pede pra criar uma "team" — escolha um nome qualquer (ex: `tulio-homelab`) e o plano **Free**

### 1.2. Criar o túnel

1. No menu lateral: **Networks → Tunnels**
2. Clique **Create a tunnel**
3. Selecione **Cloudflared** (não escolha WARP Connector)
4. Nome do túnel: `uniasselvi-sjb` → **Save tunnel**

### 1.3. Copiar o token de instalação

A Cloudflare vai te mostrar um comando estilo:

```bash
docker run cloudflare/cloudflared:latest tunnel --no-autoupdate run --token eyJhIjoi...
```

**Copie o token inteiro** (a parte depois de `--token`). Guarde num local seguro — é o que autentica o notebook no túnel.

### 1.4. Configurar o Public Hostname (deixar pra depois)

Ainda no painel do túnel, role pra baixo até **Public Hostnames**. Clique **Add a public hostname**. Por enquanto **não preencher nada** — primeiro precisamos do domínio aprovado. Voltar nessa aba depois da Etapa 3.

---

## Etapa 2 — Subir o cloudflared no homelab

O `docker-compose.yml` em `services/uniasselvi-sjb/` já inclui o serviço `cloudflared`. Basta configurar o token e subir.

### 2.1. Criar o arquivo `.env`

```bash
cd ~/uniasselvi-sjb
cp .env.example .env
nano .env
# Colar o token completo copiado no passo 1.3
```

Garantir que o `.env` está no `.gitignore`:

```bash
grep -q "^\.env$" .gitignore || echo ".env" >> .gitignore
```

### 2.2. Subir

```bash
docker compose up -d cloudflared
docker compose logs -f cloudflared
```

Deve aparecer:
```
Connection registered ... location=...
Registered tunnel connection
```

`Ctrl+C` pra sair dos logs (o container continua rodando).

**Voltar no painel da Cloudflare** → Tunnels → o túnel deve estar com status **HEALTHY** verde.

---

## Etapa 3 — Pedir o subdomínio `uniasselvi-sjb.is-a.dev`

### 3.1. Pegar o hostname do túnel

No painel da Cloudflare, abrir os detalhes do túnel. O hostname público é:

```
<TUNNEL_ID>.cfargotunnel.com
```

Anotar — vai ser usado no PR.

### 3.2. Fork e criação do JSON

1. Acessar [github.com/is-a-dev/register](https://github.com/is-a-dev/register) e clicar **Fork**
2. No fork, criar `domains/uniasselvi-sjb.json`:

```json
{
  "owner": {
    "username": "tuliodutra27",
    "email": "seu-email@exemplo.com"
  },
  "records": {
    "CNAME": "a1b2c3d4-e5f6-....cfargotunnel.com"
  },
  "proxied": true
}
```

`proxied: true` ativa o proxy da Cloudflare (HTTPS automático, DDoS protection, IP escondido). Para Cloudflare Tunnel isso é obrigatório.

### 3.3. Abrir o Pull Request

1. Commit no fork
2. **Pull Requests → New Pull Request**
3. Preencher o template e marcar os checkboxes
4. Justificar brevemente: "Internal tool for tracking new student enrollments at a Uniasselvi pole. Used by 2 internal staff members."

### 3.4. Aguardar review

**Prazo realista:** algumas horas a poucos dias, a maioria em até 24h.

> ⚠️ **Atenção:** a regra geral do is-a.dev é que o projeto seja **dev-related**. Se o PR for rejeitado por questão de escopo, considerar `is-cool.dev` ou alternativas do [Open Domains](https://www.openinternet.dev/).

---

## Etapa 4 — Conectar o domínio ao túnel (quando PR for aprovado)

Quando o PR for mergeado, os registros DNS sobem em ~5-15 minutos. Aí:

1. Voltar ao painel Cloudflare → seu túnel → aba **Public Hostnames** → **Add a public hostname**
2. Preencher:
   - **Type:** HTTP
   - **URL:** `http://app:5000`

Como o is-a.dev não está na sua conta Cloudflare, o domínio não aparece no dropdown. Existem duas saídas:

**Opção A (tentar primeiro):**

```bash
docker exec cloudflared-uniasselvi cloudflared tunnel route dns uniasselvi-sjb uniasselvi-sjb.is-a.dev
```

**Opção B (fallback):** configurar via `config.yml` local com `credentials-file` se a Opção A falhar por falta de permissão.

---

## Etapa 5 — Backup do banco SQLite

O script `scripts/04-backup-uniasselvi.sh` já está pronto. Configure e agende:

### 5.1. Ajustar o script

Editar `scripts/04-backup-uniasselvi.sh` se necessário:
- `PROJECT_DIR` → caminho real do projeto no servidor
- `/app/data/database.db` → caminho do banco dentro do container

### 5.2. Configurar rclone (uma vez)

```bash
sudo apt install rclone -y
rclone config
# n (new remote) → nome: gdrive → tipo: drive → autorizar via navegador
```

### 5.3. Testar e agendar

```bash
# Testar manualmente primeiro
bash ~/HomeLab/scripts/04-backup-uniasselvi.sh

# Cron diário às 3h da manhã
(crontab -l 2>/dev/null; echo "0 3 * * * $HOME/HomeLab/scripts/04-backup-uniasselvi.sh >> $HOME/backups/backup.log 2>&1") | crontab -
```

---

## Etapa 6 — Segurança extra com Cloudflare Access

Como a app tem **CPF de alunos**, recomenda-se fortemente uma camada extra: **Cloudflare Access**. Exige login antes de chegar na app. **Grátis até 50 usuários.**

1. Em **Zero Trust → Access → Applications → Add an application → Self-hosted**
2. Application domain: `uniasselvi-sjb.is-a.dev`
3. Criar uma policy: "Allow" com `Include: Emails ending in @seudominio.com` ou listar os emails dos usuários autorizados
4. Salvar

Agora a app exige autenticação **antes** mesmo de chegar no Flask.

---

## Checklist final

- [ ] Túnel criado e mostrando HEALTHY no painel
- [ ] `.env` criado com o token (nunca commitar)
- [ ] `cloudflared` rodando: `docker compose ps`
- [ ] `.env` no `.gitignore`
- [ ] PR no is-a.dev aprovado
- [ ] Public Hostname configurado no túnel
- [ ] `https://uniasselvi-sjb.is-a.dev` carregando a app
- [ ] Backup diário via cron funcionando
- [ ] Cloudflare Access ativo (recomendado para dados sensíveis)

---

## Ponto crítico de troubleshooting

A **Etapa 4 (Opção A)** pode falhar porque a CLI do `cloudflared` precisa de credenciais que o token simples não tem. Se rolar erro, migrar pra `config.yml` local com `credentials-file`.

**Teste rápido antes do PR ser aprovado** — valida que o pipeline do túnel funciona:

```bash
docker exec cloudflared-uniasselvi cloudflared tunnel --url http://app:5000
```

Isso retorna uma URL `.trycloudflare.com` temporária. Se carregar a app, o problema (se houver) fica restrito à integração com o is-a.dev.

---

## Comandos úteis pós-deploy

```bash
# Status dos containers
docker compose ps

# Logs do túnel (debug de conexão)
docker compose logs -f cloudflared

# Reiniciar só o túnel
docker compose restart cloudflared

# Testar backup manualmente
bash ~/HomeLab/scripts/04-backup-uniasselvi.sh

# Listar backups no Google Drive
rclone ls gdrive:backups/uniasselvi-sjb/
```

## Atualizar a app

```bash
cd ~/uniasselvi-sjb
git pull
docker compose up -d --build app
# O cloudflared não precisa reiniciar — o túnel continua de pé
```

---

## Custo total

| Item | Custo |
|------|-------|
| Cloudflare Tunnel | Grátis |
| is-a.dev | Grátis |
| Cloudflare Access (até 50 usuários) | Grátis |
| Google Drive (15 GB) | Grátis |
| Homelab (notebook) | Custo da luz |
| **Total recorrente** | **R$ 0,00** |
