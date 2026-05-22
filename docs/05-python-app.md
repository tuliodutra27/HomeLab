# Rodando Apps Python no HomeLab

## Estrutura mínima de um app Python para Docker

```
meu-app/
├── Dockerfile
├── docker-compose.yml
├── requirements.txt
└── main.py
```

### Dockerfile

```dockerfile
FROM python:3.12-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY . .
EXPOSE 8000
CMD ["python", "main.py"]
```

### docker-compose.yml

```yaml
services:
  meu-app:
    build: .
    container_name: meu-app
    restart: unless-stopped
    ports:
      - "8000:8000"
```

### Exemplo com FastAPI

`requirements.txt`:
```
fastapi
uvicorn
```

`main.py`:
```python
from fastapi import FastAPI

app = FastAPI()

@app.get("/")
def root():
    return {"status": "ok"}
```

`CMD` no Dockerfile:
```dockerfile
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
```

## Deploy via CasaOS

1. Coloque a pasta do app no servidor (via `scp` ou `git clone`)
2. No CasaOS, vá em **App Store → Custom Install**
3. Cole o conteúdo do `docker-compose.yml`
4. Clique em **Install**

## Atualizar o app após mudanças

```bash
docker compose down
docker compose build --no-cache
docker compose up -d
```

## Expor via Nginx Proxy Manager

Após o container subir na porta `8000`, crie um Proxy Host no NPM:
- Forward Host: `localhost`
- Forward Port: `8000`
- Domain: nome que quiser acessar pelo Tailscale
