# Nginx Proxy Manager — Links para os Apps

Nginx Proxy Manager (NPM) cria URLs limpas para os seus serviços, com SSL automático.

## Instalação via CasaOS

Disponível diretamente na App Store do CasaOS — busque por **Nginx Proxy Manager** e instale.

## Instalação manual (docker-compose)

Arquivo em `services/nginx-proxy-manager/docker-compose.yml`.

```bash
cd services/nginx-proxy-manager
docker compose up -d
```

## Acesso ao painel de administração

```
http://<IP-DO-SERVIDOR>:81
```

Credenciais padrão:
- E-mail: `admin@example.com`
- Senha: `changeme`

**Troque a senha imediatamente após o primeiro login.**

## Criar um Proxy Host (link para um app)

1. Acesse o painel do NPM
2. Vá em **Proxy Hosts → Add Proxy Host**
3. Preencha:
   - **Domain Name**: nome que você quer usar (ex: `meuapp.homelab`)
   - **Scheme**: `http`
   - **Forward Hostname/IP**: `localhost` ou o nome do container
   - **Forward Port**: porta que o seu app expõe
4. Salve

## Uso com Tailscale MagicDNS

Com MagicDNS ativado, você pode usar o hostname do servidor como base:

```
http://homelab.<seu-tailnet>.ts.net:porta
```

Para URLs sem porta, configure o Proxy Host no NPM apontando para o serviço desejado.
