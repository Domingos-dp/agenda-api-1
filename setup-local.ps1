# Script de Auto-Configuração - Local
# Agenda API - Configuração Automática sem Docker

Write-Host "💻 Iniciando configuração automática da Agenda API (Local)..." -ForegroundColor Cyan

# Verificar se PHP está instalado
Write-Host "📋 Verificando PHP..." -ForegroundColor Yellow
try {
    $phpVersion = php --version 2>$null
    if ($LASTEXITCODE -ne 0) {
        throw "PHP não encontrado"
    }
    Write-Host "✅ PHP encontrado: $($phpVersion.Split("`n")[0])" -ForegroundColor Green
    
    # Verificar versão do PHP
    $phpVersionNumber = [regex]::Match($phpVersion, "PHP (\d+\.\d+)").Groups[1].Value
    if ([version]$phpVersionNumber -lt [version]"8.1") {
        Write-Host "⚠️ PHP versão $phpVersionNumber detectada. Recomendado: 8.1+" -ForegroundColor Yellow
    }
} catch {
    Write-Host "❌ PHP não está instalado ou não está no PATH" -ForegroundColor Red
    Write-Host "📥 Por favor, instale o PHP 8.1+ ou configure o PATH" -ForegroundColor Yellow
    Write-Host "   Opções de instalação:" -ForegroundColor Blue
    Write-Host "   - XAMPP: https://www.apachefriends.org/" -ForegroundColor Blue
    Write-Host "   - Laravel Herd: https://herd.laravel.com/" -ForegroundColor Blue
    Write-Host "   - PHP oficial: https://www.php.net/downloads" -ForegroundColor Blue
    exit 1
}

# Verificar extensões PHP necessárias
Write-Host "🔍 Verificando extensões PHP..." -ForegroundColor Yellow
$requiredExtensions = @("pdo_pgsql", "mbstring", "openssl", "tokenizer", "xml", "ctype", "json")
$missingExtensions = @()

foreach ($extension in $requiredExtensions) {
    $result = php -m 2>$null | Select-String $extension
    if (-not $result) {
        $missingExtensions += $extension
    }
}

if ($missingExtensions.Count -gt 0) {
    Write-Host "❌ Extensões PHP faltando: $($missingExtensions -join ', ')" -ForegroundColor Red
    Write-Host "🔧 Por favor, instale as extensões necessárias" -ForegroundColor Yellow
    exit 1
} else {
    Write-Host "✅ Todas as extensões PHP necessárias estão instaladas" -ForegroundColor Green
}

# Verificar se Composer está instalado
Write-Host "📦 Verificando Composer..." -ForegroundColor Yellow
try {
    $composerVersion = composer --version 2>$null
    if ($LASTEXITCODE -ne 0) {
        throw "Composer não encontrado"
    }
    Write-Host "✅ Composer encontrado: $($composerVersion.Split("`n")[0])" -ForegroundColor Green
} catch {
    Write-Host "❌ Composer não está instalado" -ForegroundColor Red
    Write-Host "📥 Por favor, instale o Composer:" -ForegroundColor Yellow
    Write-Host "   https://getcomposer.org/download/" -ForegroundColor Blue
    exit 1
}

# Verificar PostgreSQL
Write-Host "🗄️ Verificando PostgreSQL..." -ForegroundColor Yellow
try {
    $pgVersion = psql --version 2>$null
    if ($LASTEXITCODE -ne 0) {
        throw "PostgreSQL não encontrado"
    }
    Write-Host "✅ PostgreSQL encontrado: $($pgVersion)" -ForegroundColor Green
} catch {
    Write-Host "⚠️ PostgreSQL não encontrado no PATH" -ForegroundColor Yellow
    Write-Host "📥 Certifique-se de que o PostgreSQL está instalado e configurado" -ForegroundColor Yellow
    Write-Host "   Download: https://www.postgresql.org/download/" -ForegroundColor Blue
}

# Configurar arquivo .env
Write-Host "⚙️ Configurando arquivo .env..." -ForegroundColor Yellow
if (-not (Test-Path ".env")) {
    if (Test-Path ".env.example") {
        Copy-Item ".env.example" ".env"
        Write-Host "✅ Arquivo .env criado a partir do .env.example" -ForegroundColor Green
    } else {
        Write-Host "❌ Arquivo .env.example não encontrado" -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host "✅ Arquivo .env já existe" -ForegroundColor Green
}

# Configurar banco de dados no .env
Write-Host "🔧 Configurando banco de dados..." -ForegroundColor Yellow
$envContent = Get-Content ".env"

# Solicitar configurações do banco
Write-Host "📝 Configure as credenciais do banco de dados:" -ForegroundColor Cyan
$dbHost = Read-Host "Host do PostgreSQL (padrão: 127.0.0.1)"
if ([string]::IsNullOrWhiteSpace($dbHost)) { $dbHost = "127.0.0.1" }

$dbPort = Read-Host "Porta do PostgreSQL (padrão: 5432)"
if ([string]::IsNullOrWhiteSpace($dbPort)) { $dbPort = "5432" }

$dbName = Read-Host "Nome do banco de dados (padrão: Agenda_api)"
if ([string]::IsNullOrWhiteSpace($dbName)) { $dbName = "Agenda_api" }

$dbUser = Read-Host "Usuário do PostgreSQL (padrão: postgres)"
if ([string]::IsNullOrWhiteSpace($dbUser)) { $dbUser = "postgres" }

$dbPassword = Read-Host "Senha do PostgreSQL" -AsSecureString
$dbPasswordPlain = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($dbPassword))

# Atualizar .env
$envContent = $envContent -replace "DB_CONNECTION=.*", "DB_CONNECTION=pgsql"
$envContent = $envContent -replace "DB_HOST=.*", "DB_HOST=$dbHost"
$envContent = $envContent -replace "DB_PORT=.*", "DB_PORT=$dbPort"
$envContent = $envContent -replace "DB_DATABASE=.*", "DB_DATABASE=$dbName"
$envContent = $envContent -replace "DB_USERNAME=.*", "DB_USERNAME=$dbUser"
$envContent = $envContent -replace "DB_PASSWORD=.*", "DB_PASSWORD=$dbPasswordPlain"

$envContent | Set-Content ".env"
Write-Host "✅ Configurações do banco atualizadas no .env" -ForegroundColor Green

# Instalar dependências
Write-Host "📦 Instalando dependências do Composer..." -ForegroundColor Yellow
composer install --no-interaction --optimize-autoloader

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Erro ao instalar dependências" -ForegroundColor Red
    exit 1
}

Write-Host "✅ Dependências instaladas com sucesso" -ForegroundColor Green

# Gerar chave da aplicação
Write-Host "🔑 Gerando chave da aplicação..." -ForegroundColor Yellow
php artisan key:generate --force

# Tentar criar banco de dados
Write-Host "🗄️ Tentando criar banco de dados..." -ForegroundColor Yellow
try {
    $env:PGPASSWORD = $dbPasswordPlain
    createdb -h $dbHost -p $dbPort -U $dbUser $dbName 2>$null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Banco de dados '$dbName' criado com sucesso" -ForegroundColor Green
    } else {
        Write-Host "⚠️ Banco de dados pode já existir ou erro na criação" -ForegroundColor Yellow
    }
} catch {
    Write-Host "⚠️ Não foi possível criar o banco automaticamente" -ForegroundColor Yellow
    Write-Host "🔧 Certifique-se de que o banco '$dbName' existe" -ForegroundColor Yellow
}

# Executar migrações
Write-Host "🗄️ Executando migrações..." -ForegroundColor Yellow
php artisan migrate --force

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Erro ao executar migrações" -ForegroundColor Red
    Write-Host "🔧 Verifique as configurações do banco de dados" -ForegroundColor Yellow
    exit 1
}

Write-Host "✅ Migrações executadas com sucesso" -ForegroundColor Green

# Executar seeders
Write-Host "🌱 Executando seeders..." -ForegroundColor Yellow
php artisan db:seed --force

# Limpar cache
Write-Host "🧹 Limpando cache..." -ForegroundColor Yellow
php artisan config:clear
php artisan cache:clear
php artisan route:clear

# Iniciar servidor de desenvolvimento
Write-Host "🚀 Iniciando servidor de desenvolvimento..." -ForegroundColor Yellow
Write-Host "⚠️ O servidor será iniciado em segundo plano" -ForegroundColor Yellow
Write-Host "   Para parar o servidor, feche esta janela ou pressione Ctrl+C" -ForegroundColor Yellow

Start-Sleep -Seconds 2

# Testar se a porta 8000 está livre
$portTest = Test-NetConnection -ComputerName localhost -Port 8000 -InformationLevel Quiet -WarningAction SilentlyContinue
if ($portTest) {
    Write-Host "⚠️ Porta 8000 já está em uso" -ForegroundColor Yellow
    $newPort = Read-Host "Digite uma porta alternativa (ex: 8080)"
    $serverCommand = "php artisan serve --port=$newPort"
    $serverUrl = "http://localhost:$newPort"
} else {
    $serverCommand = "php artisan serve"
    $serverUrl = "http://localhost:8000"
}

# Exibir informações finais
Write-Host ""
Write-Host "🎉 Configuração concluída com sucesso!" -ForegroundColor Green
Write-Host ""
Write-Host "📍 Para iniciar o servidor:" -ForegroundColor Cyan
Write-Host "   $serverCommand" -ForegroundColor Blue
Write-Host ""
Write-Host "📍 URLs disponíveis:" -ForegroundColor Cyan
Write-Host "   🌐 API: $serverUrl" -ForegroundColor Blue
Write-Host "   📚 Documentação Swagger: $serverUrl/api/documentation" -ForegroundColor Blue
Write-Host ""
Write-Host "🔧 Comandos úteis:" -ForegroundColor Cyan
Write-Host "   Iniciar servidor: php artisan serve" -ForegroundColor Gray
Write-Host "   Ver rotas: php artisan route:list" -ForegroundColor Gray
Write-Host "   Limpar cache: php artisan cache:clear" -ForegroundColor Gray
Write-Host "   Executar migrações: php artisan migrate" -ForegroundColor Gray
Write-Host ""

# Perguntar se deve iniciar o servidor automaticamente
$startServer = Read-Host "Deseja iniciar o servidor automaticamente? (s/N)"
if ($startServer -eq "s" -or $startServer -eq "S") {
    Write-Host "🚀 Iniciando servidor..." -ForegroundColor Green
    Write-Host "   Acesse: $serverUrl" -ForegroundColor Blue
    Write-Host "   Pressione Ctrl+C para parar o servidor" -ForegroundColor Yellow
    Write-Host ""
    
    # Executar o comando do servidor
    Invoke-Expression $serverCommand
} else {
    Write-Host "✨ Projeto configurado e pronto para uso!" -ForegroundColor Green
    Write-Host "   Execute '$serverCommand' para iniciar o servidor" -ForegroundColor Blue
}