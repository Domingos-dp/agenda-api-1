#!/bin/bash

# Script de Auto-Configuração - Docker
# Agenda API - Configuração Automática com Docker

echo "🐳 Iniciando configuração automática da Agenda API com Docker..."

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Verificar se Docker está instalado
echo -e "${YELLOW}📋 Verificando Docker...${NC}"
if ! command -v docker &> /dev/null; then
    echo -e "${RED}❌ Docker não está instalado${NC}"
    echo -e "${YELLOW}📥 Por favor, instale o Docker:${NC}"
    echo -e "${BLUE}   https://docs.docker.com/get-docker/${NC}"
    exit 1
fi

DOCKER_VERSION=$(docker --version)
echo -e "${GREEN}✅ Docker encontrado: $DOCKER_VERSION${NC}"

# Verificar se Docker está rodando
echo -e "${YELLOW}🔍 Verificando se Docker está rodando...${NC}"
if ! docker ps &> /dev/null; then
    echo -e "${RED}❌ Docker não está rodando${NC}"
    echo -e "${YELLOW}🚀 Por favor, inicie o Docker e execute este script novamente${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Docker está rodando${NC}"

# Verificar Docker Compose
echo -e "${YELLOW}🔍 Verificando Docker Compose...${NC}"
if command -v docker-compose &> /dev/null; then
    COMPOSE_CMD="docker-compose"
elif docker compose version &> /dev/null; then
    COMPOSE_CMD="docker compose"
else
    echo -e "${RED}❌ Docker Compose não encontrado${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Docker Compose encontrado${NC}"

# Configurar arquivo .env
echo -e "${YELLOW}⚙️ Configurando arquivo .env...${NC}"
if [ ! -f ".env" ]; then
    if [ -f ".env.example" ]; then
        cp ".env.example" ".env"
        echo -e "${GREEN}✅ Arquivo .env criado a partir do .env.example${NC}"
    elif [ -f ".env.docker" ]; then
        cp ".env.docker" ".env"
        echo -e "${GREEN}✅ Arquivo .env criado a partir do .env.docker${NC}"
    else
        echo -e "${RED}❌ Arquivo .env.example ou .env.docker não encontrado${NC}"
        exit 1
    fi
else
    echo -e "${GREEN}✅ Arquivo .env já existe${NC}"
fi

# Parar containers existentes
echo -e "${YELLOW}🛑 Parando containers existentes...${NC}"
$COMPOSE_CMD down 2>/dev/null

# Construir e iniciar containers
echo -e "${YELLOW}🏗️ Construindo e iniciando containers...${NC}"
if ! $COMPOSE_CMD up -d --build; then
    echo -e "${RED}❌ Erro ao iniciar containers${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Containers iniciados com sucesso${NC}"

# Aguardar containers ficarem prontos
echo -e "${YELLOW}⏳ Aguardando containers ficarem prontos...${NC}"
sleep 30

# Verificar status dos containers
echo -e "${YELLOW}📊 Verificando status dos containers...${NC}"
$COMPOSE_CMD ps

# Instalar dependências do Composer
echo -e "${YELLOW}📦 Instalando dependências do Composer...${NC}"
if ! $COMPOSE_CMD exec app composer install --no-interaction --optimize-autoloader; then
    echo -e "${RED}❌ Erro ao instalar dependências${NC}"
    exit 1
fi

# Gerar chave da aplicação
echo -e "${YELLOW}🔑 Gerando chave da aplicação...${NC}"
$COMPOSE_CMD exec app php artisan key:generate --force

# Executar migrações
echo -e "${YELLOW}🗄️ Executando migrações do banco de dados...${NC}"
if ! $COMPOSE_CMD exec app php artisan migrate --force; then
    echo -e "${RED}❌ Erro ao executar migrações${NC}"
    echo -e "${YELLOW}🔧 Tentando novamente em 10 segundos...${NC}"
    sleep 10
    $COMPOSE_CMD exec app php artisan migrate --force
fi

# Executar seeders (opcional)
echo -e "${YELLOW}🌱 Executando seeders...${NC}"
$COMPOSE_CMD exec app php artisan db:seed --force

# Limpar cache
echo -e "${YELLOW}🧹 Limpando cache...${NC}"
$COMPOSE_CMD exec app php artisan config:clear
$COMPOSE_CMD exec app php artisan cache:clear
$COMPOSE_CMD exec app php artisan route:clear

# Testar API
echo -e "${YELLOW}🧪 Testando API...${NC}"
sleep 5

if curl -s -o /dev/null -w "%{http_code}" http://localhost:8081 | grep -q "200"; then
    echo -e "${GREEN}✅ API respondendo corretamente${NC}"
else
    echo -e "${YELLOW}⚠️ Não foi possível testar a API automaticamente${NC}"
    echo -e "${BLUE}   Verifique manualmente em: http://localhost:8081${NC}"
fi

# Exibir informações finais
echo ""
echo -e "${GREEN}🎉 Configuração concluída com sucesso!${NC}"
echo ""
echo -e "${CYAN}📍 URLs disponíveis:${NC}"
echo -e "${BLUE}   🌐 API: http://localhost:8081${NC}"
echo -e "${BLUE}   📚 Documentação Swagger: http://localhost:8081/api/documentation${NC}"
echo -e "${BLUE}   🗄️ PostgreSQL: localhost:5433${NC}"
echo ""
echo -e "${CYAN}🔧 Comandos úteis:${NC}"
echo -e "   Ver logs: $COMPOSE_CMD logs -f app"
echo -e "   Parar: $COMPOSE_CMD down"
echo -e "   Reiniciar: $COMPOSE_CMD restart"
echo -e "   Executar comando: $COMPOSE_CMD exec app php artisan [comando]"
echo ""
echo -e "${GREEN}✨ Projeto pronto para uso!${NC}"