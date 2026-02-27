# Documentação do Dashboard: Monitoramento e Gestão (Fase 4)

O Dashboard do B-AILA é uma interface web externa desenvolvida em **Next.js** para fornecer controle total sobre o ecossistema fora do Blender.

## Implementação Técnica: `apps/frontend`

### 1. Visão Geral e Estética
Para garantir uma experiência premium, o dashboard utiliza:
- **Dark Mode Nativo:** Focado em artistas 3D e desenvolvedores.
- **TailwindCSS:** Para um layout responsivo e moderno.
- **Componentes Lucide:** Iconografia limpa e intuitiva.

### 2. Funcionalidades Principais
O dashboard está organizado em três áreas de foco:

#### A. Monitoramento de Performance
- Visualização em tempo real do uso de CPU e VRAM (via Ollama).
- Status de conexão das portas `8990` (Backend) e `11434` (Ollama).

#### B. Gestão de Modelos (AI Management)
- Lista de modelos instalados no Ollama (ex: `codellama`, `llama3`).
- Interface para disparar o download (`pull`) de novos modelos.

#### C. Logs e Self-Healing Explorer
- Visualização detalhada de todos os snippets de código Python gerados.
- Histórico de erros reportados pelo Add-on do Blender, permitindo analisar falhas de execução.

### 3. Integração com o Backend
O Frontend se comunica com o servidor Fastify (`:8990`) buscando dados via requisições HTTP e, futuramente, via SSE (Server-Sent Events) para atualizações em tempo real.

---

## Próximos Passos
Após a conclusão desta interface, entraremos na fase final de **Verificação Integrada**, testando todo o fluxo: `Blender Prompt -> Backend -> Ollama -> Blender Python Exec -> Dashboard Logs`.
