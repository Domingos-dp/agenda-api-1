#!/bin/bash

# Script de Auto-Configuração - Local
# Agenda API - Configuração Automática sem Docker

echo "💻 Iniciando configuração automática da Agenda API (Local)..."

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Verificar se PHP está instalado
echo -e "${YELLOW}📋 Verificando PHP...${NC}"
if ! command -v php &> /dev/null; then
    echo -e "${RED}❌ PHP não está instalado${NC}"
    echo -e "${YELLOW}📥 Por favor, instale o PHP 8.1+${NC}"
    echo -e "${BLUE}   Ubuntu/Debian: sudo apt install php8.1 php8.1-cli php8.1-common${NC}"
    echo -e "${BLUE}   CentOS/RHEL: sudo yum install php php-cli${NC}"
    echo -e "${BLUE}   macOS: brew install php${NC}"
    exit 1
fi

PHP_VERSION=$(php --version | head -n 1)
echo -e "${GREEN}✅ PHP encontrado: $PHP_VERSION${NC}"

# Verificar versão do PHP
PHP_VERSION_NUMBER=$(php --version | head -n 1 | grep -oP 'PHP \K[0-9]+\.[0-9]+')
if [[ $(echo "$PHP_VERSION_NUMBER < 8.1" | bc -l) -eq 1 ]]; then
    echo -e "${YELLOW}⚠️ PHP versão $PHP_VERSION_NUMBER detectada. Recomendado: 8.1+${NC}"
fi

# Verificar extensões PHP necessárias
echo -e "${YELLOW}🔍 Verificando extensões PHP...${NC}"
REQUIRED_EXTENSIONS=("pdo_pgsql" "mbstring" "openssl" "tokenizer" "xml" "ctype" "json")
MISSING_EXTENSIONS=()

for extension in "${REQUIRED_EXTENSIONS[@]}"; do
    if ! php -m | grep -q "$extension"; then
        MISSING_EXTENSIONS+=("$extension")
    fi
done

if [ ${#MISSING_EXTENSIONS[@]} -gt 0 ]; then
    echo -e "${RED}❌ Extensões PHP faltando: ${MISSING_EXTENSIONS[*]}${NC}"
    echo -e "${YELLOW}🔧 Instale as extensões necessárias:${NC}"
    echo -e "${BLUE}   Ubuntu/Debian: sudo apt install php8.1-pgsql php8.1-mbstring php8.1-xml${NC}"
    echo -e "${BLUE}   CentOS/RHEL: sudo yum install php-pgsql php-mbstring php-xml${NC}"
    exit 1
else
    echo -e "${GREEN}✅ Todas as extensões PHP necessárias estão instaladas${NC}"
fi

# Verificar se Composer está instalado
echo -e "${YELLOW}📦 Verificando Composer...${NC}"
if ! command -v composer &> /dev/null; then
    echo -e "${RED}❌ Composer não está instalado${NC}"
    echo -e "${YELLOW}📥 Instalando Composer...${NC}"
    
    # Baixar e instalar Composer
    curl -sS https://getcomposer.org/installer | php
    sudo mv composer.phar /usr/local/bin/composer
    
    if command -v composer &> /dev/null; then
        echo -e "${GREEN}✅ Composer instalado com sucesso${NC}"
    else
        echo -e "${RED}❌ Falha ao instalar Composer${NC}"
        echo -e "${BLUE}   Instale manualmente: https://getcomposer.org/download/${NC}"
        exit 1
    fi
else
    COMPOSER_VERSION=$(composer --version)
    echo -e "${GREEN}✅ Composer encontrado: $COMPOSER_VERSION${NC}"
fi

# Verificar PostgreSQL
echo -e "${YELLOW}🗄️ Verificando PostgreSQL...${NC}"
if ! command -v psql &> /dev/null; then
    echo -e "${YELLOW}⚠️ PostgreSQL não encontrado no PATH${NC}"
    echo -e "${YELLOW}📥 Certifique-se de que o PostgreSQL está instalado:${NC}"
    echo -e "${BLUE}   Ubuntu/Debian: sudo apt install postgresql postgresql-contrib${NC}"
    echo -e "${BLUE}   CentOS/RHEL: sudo yum install postgresql postgresql-server${NC}"
    echo -e "${BLUE}   macOS: brew install postgresql${NC}"
else
    PG_VERSION=$(psql --version)
    echo -e "${GREEN}✅ PostgreSQL encontrado: $PG_VERSION${NC}"
fi

# Configurar arquivo .env
echo -e "${YELLOW}⚙️ Configurando arquivo .env...${NC}"
if [ ! -f ".env" ]; then
    if [ -f ".env.example" ]; then
        cp ".env.example" ".env"
        echo -e "${GREEN}✅ Arquivo .env criado a partir do .env.example${NC}"
    else
        echo -e "${RED}❌ Arquivo .env.example não encontrado${NC}"
        exit 1
    fi
else
    echo -e "${GREEN}✅ Arquivo .env já existe${NC}"
fi

# Configurar banco de dados no .env
echo -e "${YELLOW}🔧 Configurando banco de dados...${NC}"
echo -e "${CYAN}📝 Configure as credenciais do banco de dados:${NC}"

read -p "Host do PostgreSQL (padrão: 127.0.0.1): " DB_HOST
DB_HOST=${DB_HOST:-127.0.0.1}

read -p "Porta do PostgreSQL (padrão: 5432): " DB_PORT
DB_PORT=${DB_PORT:-5432}

read -p "Nome do banco de dados (padrão: Agenda_api): " DB_NAME
DB_NAME=${DB_NAME:-Agenda_api}

read -p "Usuário do PostgreSQL (padrão: postgres): " DB_USER
DB_USER=${DB_USER:-postgres}

read -s -p "Senha do PostgreSQL: " DB_PASSWORD
echo

# Atualizar .env
sed -i "s/DB_CONNECTION=.*/DB_CONNECTION=pgsql/" .env
sed -i "s/DB_HOST=.*/DB_HOST=$DB_HOST/" .env
sed -i "s/DB_PORT=.*/DB_PORT=$DB_PORT/" .env
sed -i "s/DB_DATABASE=.*/DB_DATABASE=$DB_NAME/" .env
sed -i "s/DB_USERNAME=.*/DB_USERNAME=$DB_USER/" .env
sed -i "s/DB_PASSWORD=.*/DB_PASSWORD=$DB_PASSWORD/" .env

echo -e "${GREEN}✅ Configurações do banco atualizadas no .env${NC}"

# Instalar dependências
echo -e "${YELLOW}📦 Instalando dependências do Composer...${NC}"
if ! composer install --no-interaction --optimize-autoloader; then
    echo -e "${RED}❌ Erro ao instalar dependências${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Dependências instaladas com sucesso${NC}"

# Gerar chave da aplicação
echo -e "${YELLOW}🔑 Gerando chave da aplicação...${NC}"
php artisan key:generate --force

# Tentar criar banco de dados
echo -e "${YELLOW}🗄️ Tentando criar banco de dados...${NC}"
export PGPASSWORD="$DB_PASSWORD"
if createdb -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" "$DB_NAME" 2>/dev/null; then
    echo -e "${GREEN}✅ Banco de dados '$DB_NAME' criado com sucesso${NC}"
else
    echo -e "${YELLOW}⚠️ Banco de dados pode já existir ou erro na criação${NC}"
    echo -e "${YELLOW}🔧 Certifique-se de que o banco '$DB_NAME' existe${NC}"
fi

# Executar migrações
echo -e "${YELLOW}🗄️ Executando migrações...${NC}"
if ! php artisan migrate --force; then
    echo -e "${RED}❌ Erro ao executar migrações${NC}"
    echo -e "${YELLOW}🔧 Verifique as configurações do banco de dados${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Migrações executadas com sucesso${NC}"

# Executar seeders
echo -e "${YELLOW}🌱 Executando seeders...${NC}"
php artisan db:seed --force

# Limpar cache
echo -e "${YELLOW}🧹 Limpando cache...${NC}"
php artisan config:clear
php artisan cache:clear
php artisan route:clear

# Verificar se a porta 8000 está livre
echo -e "${YELLOW}🔍 Verificando porta 8000...${NC}"
if lsof -Pi :8000 -sTCP:LISTEN -t >/dev/null; then
    echo -e "${YELLOW}⚠️ Porta 8000 já está em uso${NC}"
    read -p "Digite uma porta alternativa (ex: 8080): " NEW_PORT
    SERVER_COMMAND="php artisan serve --port=$NEW_PORT"
    SERVER_URL="http://localhost:$NEW_PORT"
else
    SERVER_COMMAND="php artisan serve"
    SERVER_URL="http://localhost:8000"
fi

# Exibir informações finais
echo ""
echo -e "${GREEN}🎉 Configuração concluída com sucesso!${NC}"
echo ""
echo -e "${CYAN}📍 Para iniciar o servidor:${NC}"
echo -e "${BLUE}   $SERVER_COMMAND${NC}"
echo ""
echo -e "${CYAN}📍 URLs disponíveis:${NC}"
echo -e "${BLUE}   🌐 API: $SERVER_URL${NC}"
echo -e "${BLUE}   📚 Documentação Swagger: $SERVER_URL/api/documentation${NC}"
echo ""
echo -e "${CYAN}🔧 Comandos úteis:${NC}"
echo "   Iniciar servidor: php artisan serve"
echo "   Ver rotas: php artisan route:list"
echo "   Limpar cache: php artisan cache:clear"
echo "   Executar migrações: php artisan migrate"
echo ""

# Perguntar se deve iniciar o servidor automaticamente
read -p "Deseja iniciar o servidor automaticamente? (s/N): " START_SERVER
if [[ "$START_SERVER" =~ ^[Ss]$ ]]; then
    echo -e "${GREEN}🚀 Iniciando servidor...${NC}"
    echo -e "${BLUE}   Acesse: $SERVER_URL${NC}"
    echo -e "${YELLOW}   Pressione Ctrl+C para parar o servidor${NC}"
    echo ""
    
    # Executar o comando do servidor
    eval $SERVER_COMMAND
else
    echo -e "${GREEN}✨ Projeto configurado e pronto para uso!${NC}"
    echo -e "${BLUE}   Execute '$SERVER_COMMAND' para iniciar o servidor${NC}"
fi