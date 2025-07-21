# Docker Setup - Agenda API

## PostgreSQL 17 Configuration

Este projeto foi configurado para usar PostgreSQL 17 com Docker.

### Pré-requisitos

- Docker
- Docker Compose

### Configuração

1. **Copie o arquivo de ambiente:**
   ```bash
   cp .env.example .env
   ```

2. **Gere a chave da aplicação:**
   ```bash
   docker-compose exec app php artisan key:generate
   ```

3. **Execute as migrações:**
   ```bash
   docker-compose exec app php artisan migrate
   ```

4. **Execute os seeders (opcional):**
   ```bash
   docker-compose exec app php artisan db:seed
   ```

### Comandos Docker

#### Iniciar os serviços
```bash
docker-compose up -d
```

#### Parar os serviços
```bash
docker-compose down
```

#### Reconstruir os containers
```bash
docker-compose up --build -d
```

#### Ver logs
```bash
# Todos os serviços
docker-compose logs -f

# Apenas a aplicação
docker-compose logs -f app

# Apenas o PostgreSQL
docker-compose logs -f postgres
```

### Acesso aos Serviços

- **API:** http://localhost:8081
- **PostgreSQL:** localhost:5433
  - Database: `Agenda_api`
  - Username: `postgres`
  - Password: `Loand@2019!`

### Características do PostgreSQL 17

- **Imagem:** postgres:17-alpine (mais leve)
- **Extensões instaladas:**
  - uuid-ossp (para UUIDs)
  - pg_stat_statements (estatísticas de performance)
  - pg_trgm (busca de texto)
- **Configurações otimizadas:**
  - max_connections: 200
  - shared_buffers: 256MB
  - effective_cache_size: 1GB
  - Timezone: America/Sao_Paulo

### Health Check

O PostgreSQL possui um health check configurado que verifica se o banco está pronto para receber conexões. A aplicação só inicia após o PostgreSQL estar saudável.

### Volumes

- **pg_data:** Persiste os dados do PostgreSQL
- **./docker/postgres/init:** Scripts de inicialização do banco

### Troubleshooting

#### Problema de conexão com o banco
```bash
# Verificar se o PostgreSQL está rodando
docker-compose ps

# Verificar logs do PostgreSQL
docker-compose logs postgres

# Testar conexão
docker-compose exec postgres psql -U postgres -d Agenda_api
```

#### Resetar o banco de dados
```bash
# Parar os serviços
docker-compose down

# Remover o volume do banco
docker volume rm agenda-api_pg_data

# Iniciar novamente
docker-compose up -d
```

#### Executar comandos Artisan
```bash
# Exemplo: limpar cache
docker-compose exec app php artisan cache:clear

# Exemplo: executar migrações
docker-compose exec app php artisan migrate

# Exemplo: acessar o container
docker-compose exec app bash
```