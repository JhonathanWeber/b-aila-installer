# Instalação e Orquestração

## 1. Infraestrutura e Automação
Prepara o ambiente Windows 11 para o usuário final.

### Orquestrador PowerShell (`scripts/install.ps1`)
- **Função:** Automatizar a ativação do WSL2 (`wsl --install`), a instalação do Ollama via winget e o download do código-fonte do projeto caso não esteja presente (via `git clone`).
- **Configuração de Rede:** Criar regras de firewall para portas customizadas.
- **Isolamento:** Garantir que o ambiente de backend (Fastify) e frontend (NextJS) sejam instalados sem poluir variáveis globais.

## 2. Configuração de Portas
| Serviço | Porta Sugerida | Alterável? |
| --- | --- | --- |
| Ollama API | 11434 | Sim |
| B-AILA Backend | 8990 | Sim |
| B-AILA Dashboard | 8991 | Sim |

## 3. Backend Core (Fastify)
- **Porta Padrão:** 8990.
- **Gerenciador de Processos:** Verifica se o Ollama está ativo.
- **Monitoramento de Hardware:** Lê uso de VRAM e CPU para o dashboard.
