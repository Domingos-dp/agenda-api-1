#!/bin/bash

# Script de inicialização da Agenda API com PostgreSQL 17
# Este script automatiza o setup completo do projeto

echo "🚀 Iniciando setup da Agenda API com PostgreSQL 17..."

# Verificar se o Docker está instalado
if ! command -v docker &> /dev/null; then
    echo "❌ Docker não está instalado. Por favor, instale o Docker primeiro."
    exit 1
fi

if ! command -v docker-compose &> /dev/null; then
    echo "❌ Docker Compose não está instalado. Por favor, instale o Docker Compose primeiro."
    exit 1
fi

echo "✅ Docker e Docker Compose encontrados"

# Criar arquivo .env se não existir
if [ ! -f .env ]; then
    echo "📝 Criando arquivo .env..."
    cp .env.example .env
    echo "✅ Arquivo .env criado"
else
    echo "✅ Arquivo .env já existe"
fi

# Parar containers existentes
echo "🛑 Parando containers existentes..."
docker-compose down

# Construir e iniciar os containers
echo "🔨 Construindo e iniciando containers..."
docker-compose up --build -d

# Aguardar o PostgreSQL ficar pronto
echo "⏳ Aguardando PostgreSQL ficar pronto..."
sleep 30

# Verificar se os containers estão rodando
if ! docker-compose ps | grep -q "Up"; then
    echo "❌ Erro ao iniciar os containers. Verificando logs..."
    docker-compose logs
    exit 1
fi

echo "✅ Containers iniciados com sucesso"

# Gerar chave da aplicação
echo "🔑 Gerando chave da aplicação..."
docker-compose exec -T app php artisan key:generate

# Executar migrações
echo "📊 Executando migrações do banco de dados..."
docker-compose exec -T app php artisan migrate --force

# Executar seeders (opcional)
read -p "🌱 Deseja executar os seeders? (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "🌱 Executando seeders..."
    docker-compose exec -T app php artisan db:seed --force
fi

# Limpar cache
echo "🧹 Limpando cache..."
docker-compose exec -T app php artisan cache:clear
docker-compose exec -T app php artisan config:clear
docker-compose exec -T app php artisan route:clear

echo ""
echo "🎉 Setup concluído com sucesso!"
echo ""
echo "📋 Informações dos serviços:"
echo "   🌐 API: http://localhost:8081"
echo "   🗄️  PostgreSQL: localhost:5433"
echo "   📚 Database: Agenda_api"
echo "   👤 Username: postgres"
echo "   🔒 Password: Loand@2019!"
echo ""
echo "📖 Para mais informações, consulte o arquivo DOCKER.md"
echo ""
echo "🔧 Comandos úteis:"
echo "   docker-compose logs -f          # Ver logs"
echo "   docker-compose exec app bash    # Acessar container da aplicação"
echo "   docker-compose down             # Parar serviços"
echo "   docker-compose up -d            # Iniciar serviços"