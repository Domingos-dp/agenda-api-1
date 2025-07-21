-- Script de inicialização do PostgreSQL 17
-- Este script é executado automaticamente quando o container é criado

-- Criar extensões úteis
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pg_stat_statements";
CREATE EXTENSION IF NOT EXISTS "pg_trgm";

-- Configurar timezone padrão
SET timezone = 'America/Sao_Paulo';

-- Criar índices para melhor performance (se necessário)
-- Estes serão criados após as migrações do Laravel

-- Log de inicialização
DO $$
BEGIN
    RAISE NOTICE 'PostgreSQL 17 inicializado com sucesso!';
    RAISE NOTICE 'Extensões instaladas: uuid-ossp, pg_stat_statements, pg_trgm';
    RAISE NOTICE 'Timezone configurado: America/Sao_Paulo';
END $$;