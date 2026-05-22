# Tailscale — Acesso Remoto

Tailscale cria uma VPN mesh usando WireGuard. Funciona mesmo atrás de CGNAT.

## Instalação

```bash
curl -fsSL https://tailscale.com/install.sh | sh
```

## Ativar e autenticar

```bash
sudo tailscale up
```

Um link será exibido no terminal. Abra no navegador, faça login com sua conta Tailscale e o dispositivo será adicionado à sua rede.

## Ativar na inicialização

```bash
sudo systemctl enable --now tailscaled
```

## Verificar status

```bash
tailscale status
```

## MagicDNS

Ative o MagicDNS no painel do Tailscale em:
**DNS → Enable MagicDNS**

Com isso, seus dispositivos ganham nomes como `homelab.tail12345.ts.net` em vez de IPs.

## Compartilhar acesso com outras pessoas

1. Acesse o painel em https://login.tailscale.com/admin
2. Vá em **Users → Invite users**
3. Envie o convite por e-mail
4. O convidado cria conta, instala o Tailscale no dispositivo dele e aceita o convite
5. Ele passa a enxergar os dispositivos que você liberar

## Verificar IP do servidor no tailnet

```bash
tailscale ip -4
```
