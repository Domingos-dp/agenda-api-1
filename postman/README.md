# 🧪 Testes Postman - Agenda API

Este diretório contém os scripts de teste para a Agenda API usando o Postman.

## 📁 Arquivos Incluídos

- **`Agenda-API-Collection.json`** - Collection completa com todas as rotas da API
- **`Agenda-API-Environment.json`** - Arquivo de ambiente com variáveis necessárias
- **`README.md`** - Este arquivo com instruções de uso

## 🚀 Como Usar

### 1. Importar no Postman

1. Abra o Postman
2. Clique em **Import** (ou use Ctrl+O)
3. Selecione os arquivos:
   - `Agenda-API-Collection.json`
   - `Agenda-API-Environment.json`
4. Clique em **Import**

### 2. Configurar o Ambiente

1. No canto superior direito, selecione o ambiente **"Agenda API - Environment"**
2. Verifique se a variável `base_url` está configurada corretamente:
   - **Docker**: `http://localhost:8081`
   - **Local**: `http://localhost:8000`

### 3. Executar os Testes

#### Ordem Recomendada:

1. **🔐 Autenticação**
   - Execute primeiro "Registro de Usuário" ou "Login"
   - O token será automaticamente salvo nas variáveis

2. **👥 Usuários**
   - Teste as operações de usuários

3. **📅 Agendamentos**
   - Crie, liste, atualize e exclua agendamentos

4. **🔔 Lembretes**
   - Teste as operações de lembretes

5. **🧪 Testes de Validação**
   - Execute testes de erro e validação

6. **📊 Informações da API**
   - Verifique status e documentação

## 🔧 Variáveis Automáticas

A collection está configurada para automaticamente:

- ✅ Salvar o token de autenticação após login/registro
- ✅ Salvar IDs de usuário, agendamento e lembrete
- ✅ Usar essas variáveis em requisições subsequentes
- ✅ Executar testes de validação automáticos

## 📋 Endpoints Incluídos

### 🔐 Autenticação
- `POST /api/register` - Registro de usuário
- `POST /api/login` - Login
- `POST /api/logout` - Logout
- `POST /api/forgot-password` - Esqueci minha senha

### 👥 Usuários
- `GET /api/users` - Listar usuários
- `GET /api/users?filters` - Listar com filtros
- `GET /api/users/{id}` - Detalhes do usuário
- `PUT /api/users/{id}` - Atualizar usuário

### 📅 Agendamentos
- `POST /api/appointments` - Criar agendamento
- `GET /api/appointments` - Listar agendamentos
- `GET /api/appointments?filters` - Listar com filtros
- `GET /api/appointments/{id}` - Detalhes do agendamento
- `PUT /api/appointments/{id}` - Atualizar agendamento
- `DELETE /api/appointments/{id}` - Excluir agendamento

### 🔔 Lembretes
- `POST /api/reminders` - Criar lembrete
- `GET /api/reminders` - Listar lembretes
- `GET /api/reminders?filters` - Listar com filtros
- `GET /api/reminders/{id}` - Detalhes do lembrete
- `PUT /api/reminders/{id}` - Atualizar lembrete
- `DELETE /api/reminders/{id}` - Excluir lembrete

### 📊 Informações
- `GET /` - Status da API
- `GET /api/documentation` - Documentação Swagger

## 🧪 Testes Automáticos

Cada requisição inclui testes automáticos que verificam:

- ✅ Status codes corretos
- ✅ Estrutura das respostas
- ✅ Presença de campos obrigatórios
- ✅ Salvamento automático de variáveis
- ✅ Validação de erros

## 🔍 Filtros Disponíveis

### Usuários
- `name` - Filtrar por nome
- `role` - Filtrar por função (user, admin)
- `per_page` - Itens por página

### Agendamentos
- `status` - Status (scheduled, completed, cancelled)
- `start_date` - Data inicial (YYYY-MM-DD)
- `end_date` - Data final (YYYY-MM-DD)
- `per_page` - Itens por página

### Lembretes
- `status` - Status (pending, sent, failed)
- `notification_method` - Método (email, sms, push)
- `start_date` - Data inicial (YYYY-MM-DD)
- `end_date` - Data final (YYYY-MM-DD)
- `per_page` - Itens por página

## 🚨 Testes de Erro

A collection inclui testes específicos para validar:

- ❌ Registro com dados inválidos (422)
- ❌ Acesso sem token de autenticação (401)
- ❌ Agendamento com data inválida (422)
- ❌ Outros cenários de erro

## 💡 Dicas de Uso

1. **Execute em ordem**: Comece sempre pela autenticação
2. **Verifique variáveis**: Certifique-se de que as variáveis estão sendo salvas
3. **Use filtros**: Teste diferentes combinações de filtros
4. **Valide erros**: Execute os testes de validação para verificar tratamento de erros
5. **Monitore logs**: Verifique os logs da aplicação para debugging

## 🔄 Executar Collection Completa

Para executar todos os testes automaticamente:

1. Clique no nome da collection
2. Clique em **Run**
3. Selecione todas as requisições
4. Clique em **Run Agenda API - Collection**

## 📞 Suporte

Se encontrar problemas:

1. Verifique se a API está rodando
2. Confirme a URL base no ambiente
3. Verifique os logs da aplicação
4. Consulte a documentação da API

---

**Desenvolvido para a Agenda API** 🚀