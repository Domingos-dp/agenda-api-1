# Script de Auto-Configuração - Docker
# Agenda API - Configuração Automática com Docker

Write-Host "🐳 Iniciando configuração automática da Agenda API com Docker..." -ForegroundColor Cyan

# Verificar se Docker está instalado e rodando
Write-Host "📋 Verificando Docker..." -ForegroundColor Yellow
try {
    $dockerVersion = docker --version 2>$null
    if ($LASTEXITCODE -ne 0) {
        throw "Docker não encontrado"
    }
    Write-Host "✅ Docker encontrado: $dockerVersion" -ForegroundColor Green
} catch {
    Write-Host "❌ Docker não está instalado ou não está no PATH" -ForegroundColor Red
    Write-Host "📥 Por favor, instale o Docker Desktop:" -ForegroundColor Yellow
    Write-Host "   https://www.docker.com/products/docker-desktop" -ForegroundColor Blue
    exit 1
}

# Verificar se Docker está rodando
Write-Host "🔍 Verificando se Docker está rodando..." -ForegroundColor Yellow
try {
    docker ps 2>$null | Out-Null
    if ($LASTEXITCODE -ne 0) {
        throw "Docker não está rodando"
    }
    Write-Host "✅ Docker está rodando" -ForegroundColor Green
} catch {
    Write-Host "❌ Docker não está rodando" -ForegroundColor Red
    Write-Host "🚀 Iniciando Docker Desktop..." -ForegroundColor Yellow
    
    # Tentar iniciar Docker Desktop
    $dockerDesktopPath = "C:\Program Files\Docker\Docker\Docker Desktop.exe"
    if (Test-Path $dockerDesktopPath) {
        Start-Process $dockerDesktopPath
        Write-Host "⏳ Aguardando Docker Desktop iniciar (60 segundos)..." -ForegroundColor Yellow
        Start-Sleep -Seconds 60
        
        # Verificar novamente
        try {
            docker ps 2>$null | Out-Null
            if ($LASTEXITCODE -eq 0) {
                Write-Host "✅ Docker Desktop iniciado com sucesso" -ForegroundColor Green
            } else {
                throw "Docker ainda não está respondendo"
            }
        } catch {
            Write-Host "❌ Não foi possível iniciar o Docker automaticamente" -ForegroundColor Red
            Write-Host "🔧 Por favor, inicie o Docker Desktop manualmente e execute este script novamente" -ForegroundColor Yellow
            exit 1
        }
    } else {
        Write-Host "❌ Docker Desktop não encontrado no caminho padrão" -ForegroundColor Red
        Write-Host "🔧 Por favor, inicie o Docker Desktop manualmente e execute este script novamente" -ForegroundColor Yellow
        exit 1
    }
}

# Verificar se docker-compose está disponível
Write-Host "🔍 Verificando Docker Compose..." -ForegroundColor Yellow
try {
    docker-compose --version 2>$null | Out-Null
    if ($LASTEXITCODE -ne 0) {
        # Tentar docker compose (versão mais nova)
        docker compose version 2>$null | Out-Null
        if ($LASTEXITCODE -ne 0) {
            throw "Docker Compose não encontrado"
        } else {
            $composeCommand = "docker compose"
        }
    } else {
        $composeCommand = "docker-compose"
    }
    Write-Host "✅ Docker Compose encontrado" -ForegroundColor Green
} catch {
    Write-Host "❌ Docker Compose não encontrado" -ForegroundColor Red
    exit 1
}

# Configurar arquivo .env
Write-Host "⚙️ Configurando arquivo .env..." -ForegroundColor Yellow
if (-not (Test-Path ".env")) {
    if (Test-Path ".env.example") {
        Copy-Item ".env.example" ".env"
        Write-Host "✅ Arquivo .env criado a partir do .env.example" -ForegroundColor Green
    } elseif (Test-Path ".env.docker") {
        Copy-Item ".env.docker" ".env"
        Write-Host "✅ Arquivo .env criado a partir do .env.docker" -ForegroundColor Green
    } else {
        Write-Host "❌ Arquivo .env.example ou .env.docker não encontrado" -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host "✅ Arquivo .env já existe" -ForegroundColor Green
}

# Parar containers existentes (se houver)
Write-Host "🛑 Parando containers existentes..." -ForegroundColor Yellow
& $composeCommand.Split() down 2>$null

# Construir e iniciar containers
Write-Host "🏗️ Construindo e iniciando containers..." -ForegroundColor Yellow
& $composeCommand.Split() up -d --build

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Erro ao iniciar containers" -ForegroundColor Red
    exit 1
}

Write-Host "✅ Containers iniciados com sucesso" -ForegroundColor Green

# Aguardar containers ficarem prontos
Write-Host "⏳ Aguardando containers ficarem prontos..." -ForegroundColor Yellow
Start-Sleep -Seconds 30

# Verificar status dos containers
Write-Host "📊 Verificando status dos containers..." -ForegroundColor Yellow
& $composeCommand.Split() ps

# Instalar dependências do Composer
Write-Host "📦 Instalando dependências do Composer..." -ForegroundColor Yellow
& $composeCommand.Split() exec app composer install --no-interaction --optimize-autoloader

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Erro ao instalar dependências" -ForegroundColor Red
    exit 1
}

# Gerar chave da aplicação
Write-Host "🔑 Gerando chave da aplicação..." -ForegroundColor Yellow
& $composeCommand.Split() exec app php artisan key:generate --force

# Executar migrações
Write-Host "🗄️ Executando migrações do banco de dados..." -ForegroundColor Yellow
& $composeCommand.Split() exec app php artisan migrate --force

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Erro ao executar migrações" -ForegroundColor Red
    Write-Host "🔧 Tentando novamente em 10 segundos..." -ForegroundColor Yellow
    Start-Sleep -Seconds 10
    & $composeCommand.Split() exec app php artisan migrate --force
}

# Executar seeders (opcional)
Write-Host "🌱 Executando seeders..." -ForegroundColor Yellow
& $composeCommand.Split() exec app php artisan db:seed --force

# Limpar cache
Write-Host "🧹 Limpando cache..." -ForegroundColor Yellow
& $composeCommand.Split() exec app php artisan config:clear
& $composeCommand.Split() exec app php artisan cache:clear
& $composeCommand.Split() exec app php artisan route:clear

# Testar API
Write-Host "🧪 Testando API..." -ForegroundColor Yellow
Start-Sleep -Seconds 5

try {
    $response = Invoke-WebRequest -Uri "http://localhost:8081" -Method GET -TimeoutSec 10
    if ($response.StatusCode -eq 200) {
        Write-Host "✅ API respondendo corretamente" -ForegroundColor Green
    } else {
        Write-Host "⚠️ API respondeu com status: $($response.StatusCode)" -ForegroundColor Yellow
    }
} catch {
    Write-Host "⚠️ Não foi possível testar a API automaticamente" -ForegroundColor Yellow
    Write-Host "   Verifique manualmente em: http://localhost:8081" -ForegroundColor Blue
}

# Exibir informações finais
Write-Host ""
Write-Host "🎉 Configuração concluída com sucesso!" -ForegroundColor Green
Write-Host ""
Write-Host "📍 URLs disponíveis:" -ForegroundColor Cyan
Write-Host "   🌐 API: http://localhost:8081" -ForegroundColor Blue
Write-Host "   📚 Documentação Swagger: http://localhost:8081/api/documentation" -ForegroundColor Blue
Write-Host "   🗄️ PostgreSQL: localhost:5433" -ForegroundColor Blue
Write-Host ""
Write-Host "🔧 Comandos úteis:" -ForegroundColor Cyan
Write-Host "   Ver logs: $composeCommand logs -f app" -ForegroundColor Gray
Write-Host "   Parar: $composeCommand down" -ForegroundColor Gray
Write-Host "   Reiniciar: $composeCommand restart" -ForegroundColor Gray
Write-Host "   Executar comando: $composeCommand exec app php artisan [comando]" -ForegroundColor Gray
Write-Host ""
Write-Host "✨ Projeto pronto para uso!" -ForegroundColor Green