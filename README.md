# 📅 Agenda API

Uma API REST completa para gerenciamento de agendamentos e lembretes, desenvolvida em Laravel 12 com PostgreSQL 17.

## 🚀 Funcionalidades

- **Autenticação JWT** - Sistema completo de login/registro
- **Gerenciamento de Usuários** - CRUD completo com soft deletes
- **Agendamentos** - Criação, edição e consulta de appointments
- **Lembretes** - Sistema de notificações e lembretes
- **API RESTful** - Endpoints padronizados com documentação Swagger
- **Filtros Avançados** - Sistema de filtros para consultas
- **Validações** - Validações robustas em todas as operações
- **Internacionalização** - Suporte a português brasileiro

## 🛠️ Tecnologias

- **Backend**: Laravel 12.17.0
- **Banco de Dados**: PostgreSQL 17
- **Autenticação**: Laravel Sanctum
- **Documentação**: L5-Swagger (OpenAPI)
- **Containerização**: Docker & Docker Compose
- **Cache**: Redis (via Docker)

## 📋 Pré-requisitos

### Para Docker (Recomendado)
- Docker Desktop
- Docker Compose

### Para Instalação Local
- PHP 8.1+
- Composer
- PostgreSQL 12+
- Extensões PHP: pdo_pgsql, mbstring, openssl, tokenizer, xml, ctype, json

## 🐳 Instalação com Docker (Recomendado)

### 1. Clone o repositório
```bash
git clone <repository-url>
cd agenda-api
```

### 2. Execute o script de configuração
```bash
# Windows
.\setup-docker.ps1

# Linux/Mac
./setup-docker.sh
```

### 3. Acesse a aplicação
- **API**: http://localhost:8081
- **Documentação Swagger**: http://localhost:8081/api/documentation
- **PostgreSQL**: localhost:5433

## 💻 Instalação Local (Sem Docker)

### 1. Execute o script de configuração
```bash
# Windows
.\setup-local.ps1

# Linux/Mac
./setup-local.sh
```

### 2. Configure o banco de dados
Edite o arquivo `.env` com suas credenciais do PostgreSQL:
```env
DB_CONNECTION=pgsql
DB_HOST=127.0.0.1
DB_PORT=5432
DB_DATABASE=Agenda_api
DB_USERNAME=postgres
DB_PASSWORD=sua_senha
```

### 3. Acesse a aplicação
- **API**: http://localhost:8000
- **Documentação Swagger**: http://localhost:8000/api/documentation

## 📚 Documentação da API

### Endpoints Principais

#### Autenticação
- `POST /api/register` - Registro de usuário
- `POST /api/login` - Login
- `POST /api/logout` - Logout
- `POST /api/forgot-password` - Recuperação de senha

#### Usuários
- `GET /api/users` - Listar usuários
- `GET /api/users/{id}` - Detalhes do usuário
- `PUT /api/users/{id}` - Atualizar usuário
- `DELETE /api/users/{id}` - Excluir usuário (soft delete)

#### Agendamentos
- `GET /api/appointments` - Listar agendamentos
- `POST /api/appointments` - Criar agendamento
- `GET /api/appointments/{id}` - Detalhes do agendamento
- `PUT /api/appointments/{id}` - Atualizar agendamento
- `DELETE /api/appointments/{id}` - Excluir agendamento

#### Lembretes
- `GET /api/reminders` - Listar lembretes
- `POST /api/reminders` - Criar lembrete
- `GET /api/reminders/{id}` - Detalhes do lembrete
- `PUT /api/reminders/{id}` - Atualizar lembrete
- `DELETE /api/reminders/{id}` - Excluir lembrete

### Filtros Disponíveis
- **Usuários**: nome, email, telefone, role
- **Agendamentos**: título, data, status, usuário
- **Lembretes**: título, data, tipo, status

## 🔧 Comandos Úteis

### Docker
```bash
# Iniciar containers
docker-compose up -d

# Ver logs
docker-compose logs -f app

# Executar comandos Artisan
docker-compose exec app php artisan [comando]

# Parar containers
docker-compose down

# Rebuild containers
docker-compose up -d --build
```

### Local
```bash
# Iniciar servidor de desenvolvimento
php artisan serve

# Executar migrações
php artisan migrate

# Executar seeders
php artisan db:seed

# Limpar cache
php artisan cache:clear

# Ver rotas
php artisan route:list
```

## 🗄️ Estrutura do Banco de Dados

### Tabelas Principais
- **users** - Usuários do sistema
- **appointments** - Agendamentos
- **reminders** - Lembretes
- **personal_access_tokens** - Tokens de autenticação
- **password_resets** - Reset de senhas

### Relacionamentos
- Usuário → Agendamentos (1:N)
- Usuário → Lembretes (1:N)
- Agendamento → Lembretes (1:N)

## 🧪 Testes

```bash
# Executar todos os testes
php artisan test

# Executar testes específicos
php artisan test --filter=UserTest

# Executar com coverage
php artisan test --coverage
```

## 📁 Estrutura do Projeto

```
agenda-api/
├── app/
│   ├── Http/Controllers/     # Controllers da API
│   ├── Models/              # Models Eloquent
│   ├── Services/            # Lógica de negócio
│   ├── Filters/             # Filtros para consultas
│   └── Swagger/             # Documentação OpenAPI
├── database/
│   ├── migrations/          # Migrações do banco
│   ├── seeders/            # Seeders para dados iniciais
│   └── factories/          # Factories para testes
├── routes/
│   ├── api.php             # Rotas da API
│   └── web.php             # Rotas web
├── docker/                 # Configurações Docker
├── scripts/                # Scripts de configuração
└── docs/                   # Documentação adicional
```

## 🔒 Segurança

- Autenticação via Laravel Sanctum
- Validação de dados em todas as requisições
- Rate limiting configurado
- CORS configurado para desenvolvimento
- Sanitização de inputs
- Soft deletes para preservar dados

## 🌍 Internacionalização

O projeto suporta português brasileiro com:
- Mensagens de validação traduzidas
- Mensagens de erro personalizadas
- Formatação de datas em PT-BR

## 📝 Logs

Os logs são armazenados em:
- **Docker**: `storage/logs/laravel.log`
- **Local**: `storage/logs/laravel.log`

## 🤝 Contribuição

1. Fork o projeto
2. Crie uma branch para sua feature (`git checkout -b feature/AmazingFeature`)
3. Commit suas mudanças (`git commit -m 'Add some AmazingFeature'`)
4. Push para a branch (`git push origin feature/AmazingFeature`)
5. Abra um Pull Request

## 📄 Licença

Este projeto está sob a licença MIT. Veja o arquivo `LICENSE` para mais detalhes.

## 🆘 Suporte

Se encontrar problemas:

1. Verifique se o Docker está rodando (para instalação Docker)
2. Verifique as configurações do `.env`
3. Consulte os logs em `storage/logs/laravel.log`
4. Execute `php artisan config:clear` e `php artisan cache:clear`

## 📞 Contato

Para dúvidas ou sugestões, entre em contato através dos issues do GitHub.