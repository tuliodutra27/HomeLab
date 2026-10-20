# Câmera — Samsung S21 FE com IP Webcam

O celular transmite na rede de casa (`192.168.1.115:8080`). O **go2rtc** roda no servidor, puxa esse stream e o republica. De fora de casa você acessa o go2rtc pelo Tailscale. Nenhuma porta é aberta no roteador.

```
S21 FE (IP Webcam) ──LAN──> go2rtc (servidor :1984) ──Tailscale──> celular/notebook fora de casa
```

Por que não acessar o celular direto:
- o celular só recebe **uma** conexão (a do go2rtc), não importa quantas pessoas estejam assistindo
- WebRTC/MSE no navegador: baixa latência e menos banda que MJPEG
- não precisa instalar Tailscale no celular-câmera

## 1. Preparar o celular

No app **IP Webcam**:

1. **Configurações de vídeo → Resolução**: `1280x720` (bom equilíbrio entre qualidade e banda)
2. **Configurações locais → Login/Senha**: defina um usuário e uma senha (sem isso, qualquer um na rede de casa vê a câmera)
3. **Opções de energia → Impedir suspensão**: ativado
4. **Iniciar servidor**

No Android (S21 FE):

- **Configurações → Aplicativos → IP Webcam → Bateria → Sem restrições** (senão o Android encerra o app)
- **Configurações → Assistência do aparelho e bateria → Bateria → Proteger bateria** (limita a carga em 85%; importante porque o celular vai ficar 24h na tomada)
- Deixe o celular em local ventilado, sem capa, para evitar superaquecimento

No roteador:

- Crie uma **reserva de DHCP** para o celular em `192.168.1.115`, para o IP não mudar

Teste da própria rede de casa: abra `http://192.168.1.115:8080` no navegador.

## 2. Subir o go2rtc

Arquivos em `services/go2rtc/`.

### Opção rápida (script)

```bash
bash scripts/04-install-go2rtc.sh
```

O script testa se o celular responde, pede as senhas, cria o `.env`, sobe o container e mostra as URLs.

### Opção manual

```bash
cd services/go2rtc
cp .env.example .env
nano .env          # preencha as senhas (CAM_USER/CAM_PASS = as mesmas do app)
docker compose up -d
docker logs -f go2rtc
```

O container usa `network_mode: host`, então fica escutando direto no servidor:

| Função | Porta |
|--------|-------|
| Painel web / API | 1984 |
| RTSP (para VLC, Frigate etc.) | 8554 |
| WebRTC | 8555 (tcp/udp) |

## 3. Assistir

Descubra o IP Tailscale do servidor:

```bash
tailscale ip -4
```

De qualquer dispositivo conectado ao seu Tailscale (casa ou rua):

| O quê | URL |
|-------|-----|
| Painel go2rtc | `http://<IP-TAILSCALE>:1984` |
| Stream direto no navegador | `http://<IP-TAILSCALE>:1984/stream.html?src=s21fe` |
| Foto atual (JPEG) | `http://<IP-TAILSCALE>:1984/api/frame.jpeg?src=s21fe` |
| RTSP (VLC) | `rtsp://<IP-TAILSCALE>:8554/s21fe` |

> Dica: salve a URL do `stream.html` na tela inicial do celular para ter um "app" da câmera.

## Problemas comuns

**Stream `s21fe` não abre / erro no RTSP**
Algumas versões do IP Webcam usam outro caminho RTSP. Abra `http://192.168.1.115:8080` e confira o endereço RTSP que o app mostra, ou use o fallback MJPEG:
`http://<IP-TAILSCALE>:1984/stream.html?src=s21fe_mjpeg`

**Vídeo carrega na LAN mas fica preto fora de casa**
O go2rtc cai automaticamente para MSE quando o WebRTC falha, então normalmente funciona mesmo assim. Se não funcionar, adicione o IP Tailscale do servidor como candidato WebRTC em `config/go2rtc.yaml`:

```yaml
webrtc:
  listen: ":8555"
  candidates:
    - <IP-TAILSCALE>:8555
```

e reinicie: `docker compose restart`.

**Imagem trava depois de algumas horas**
Quase sempre é o Android matando o app. Confira a otimização de bateria (passo 1).
