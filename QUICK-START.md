# 🚀 Início Rápido - Agenda API

## Escolha sua forma de instalação:

### 🐳 Com Docker (Recomendado)
```bash
# Windows
.\setup-docker.ps1

# Linux/Mac
./setup-docker.sh
```

### 💻 Sem Docker (Local)
```bash
# Windows
.\setup-local.ps1

# Linux/Mac
./setup-local.sh
```

## 📍 URLs após instalação:

### Docker
- **API**: http://localhost:8081
- **Swagger**: http://localhost:8081/api/documentation
- **PostgreSQL**: localhost:5433

### Local
- **API**: http://localhost:8000
- **Swagger**: http://localhost:8000/api/documentation

## 🔧 Comandos úteis:

### Docker
```bash
# Iniciar
docker-compose up -d

# Parar
docker-compose down

# Ver logs
docker-compose logs -f app

# Executar comando
docker-compose exec app php artisan [comando]
```

### Local
```bash
# Iniciar servidor
php artisan serve

# Migrações
php artisan migrate

# Seeders
php artisan db:seed

# Limpar cache
php artisan cache:clear
```

## 📚 Documentação completa:
Veja o arquivo `README.md` para informações detalhadas.