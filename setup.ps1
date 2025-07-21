# Script de inicialização da Agenda API com PostgreSQL 17 (Windows)
# Este script automatiza o setup completo do projeto

Write-Host "🚀 Iniciando setup da Agenda API com PostgreSQL 17..." -ForegroundColor Green

# Verificar se o Docker está instalado
try {
    docker --version | Out-Null
    Write-Host "✅ Docker encontrado" -ForegroundColor Green
} catch {
    Write-Host "❌ Docker não está instalado. Por favor, instale o Docker Desktop primeiro." -ForegroundColor Red
    exit 1
}

try {
    docker-compose --version | Out-Null
    Write-Host "✅ Docker Compose encontrado" -ForegroundColor Green
} catch {
    Write-Host "❌ Docker Compose não está instalado. Por favor, instale o Docker Compose primeiro." -ForegroundColor Red
    exit 1
}

# Criar arquivo .env se não existir
if (-not (Test-Path ".env")) {
    Write-Host "📝 Criando arquivo .env..." -ForegroundColor Yellow
    Copy-Item ".env.example" ".env"
    Write-Host "✅ Arquivo .env criado" -ForegroundColor Green
} else {
    Write-Host "✅ Arquivo .env já existe" -ForegroundColor Green
}

# Parar containers existentes
Write-Host "🛑 Parando containers existentes..." -ForegroundColor Yellow
docker-compose down

# Construir e iniciar os containers
Write-Host "🔨 Construindo e iniciando containers..." -ForegroundColor Yellow
docker-compose up --build -d

# Aguardar o PostgreSQL ficar pronto
Write-Host "⏳ Aguardando PostgreSQL ficar pronto..." -ForegroundColor Yellow
Start-Sleep -Seconds 30

# Verificar se os containers estão rodando
$containersStatus = docker-compose ps
if ($containersStatus -notmatch "Up") {
    Write-Host "❌ Erro ao iniciar os containers. Verificando logs..." -ForegroundColor Red
    docker-compose logs
    exit 1
}

Write-Host "✅ Containers iniciados com sucesso" -ForegroundColor Green

# Gerar chave da aplicação
Write-Host "🔑 Gerando chave da aplicação..." -ForegroundColor Yellow
docker-compose exec -T app php artisan key:generate

# Executar migrações
Write-Host "📊 Executando migrações do banco de dados..." -ForegroundColor Yellow
docker-compose exec -T app php artisan migrate --force

# Executar seeders (opcional)
$runSeeders = Read-Host "🌱 Deseja executar os seeders? (y/n)"
if ($runSeeders -eq "y" -or $runSeeders -eq "Y") {
    Write-Host "🌱 Executando seeders..." -ForegroundColor Yellow
    docker-compose exec -T app php artisan db:seed --force
}

# Limpar cache
Write-Host "🧹 Limpando cache..." -ForegroundColor Yellow
docker-compose exec -T app php artisan cache:clear
docker-compose exec -T app php artisan config:clear
docker-compose exec -T app php artisan route:clear

Write-Host ""
Write-Host "🎉 Setup concluído com sucesso!" -ForegroundColor Green
Write-Host ""
Write-Host "📋 Informações dos serviços:" -ForegroundColor Cyan
Write-Host "   🌐 API: http://localhost:8081" -ForegroundColor White
Write-Host "   🗄️  PostgreSQL: localhost:5433" -ForegroundColor White
Write-Host "   📚 Database: Agenda_api" -ForegroundColor White
Write-Host "   👤 Username: postgres" -ForegroundColor White
Write-Host "   🔒 Password: Loand@2019!" -ForegroundColor White
Write-Host ""
Write-Host "📖 Para mais informações, consulte o arquivo DOCKER.md" -ForegroundColor Cyan
Write-Host ""
Write-Host "🔧 Comandos úteis:" -ForegroundColor Cyan
Write-Host "   docker-compose logs -f          # Ver logs" -ForegroundColor White
Write-Host "   docker-compose exec app bash    # Acessar container da aplicação" -ForegroundColor White
Write-Host "   docker-compose down             # Parar serviços" -ForegroundColor White
Write-Host "   docker-compose up -d            # Iniciar serviços" -ForegroundColor White