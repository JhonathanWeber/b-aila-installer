# B-AILA (Blender AI Local Assistant)

B-AILA é um ecossistema local-first projetado para integrar IA generativa diretamente no fluxo de trabalho do Blender 3D.

## Estrutura do Projeto

- **`docs/`**: Documentação técnica detalhada extraída das especificações originais.
  - [Arquitetura](docs/architecture.md)
  - [Protocolo de Comunicação](docs/api_protocol.md)
  - [Guia de Instalação](docs/installation.md)
  - [Guia de Desinstalação](docs/uninstallation_guide.md)
  - [Manual do Usuário](docs/user_manual.md)
- **`apps/`**: Código fonte das aplicações.
  - `backend/`: API Fastify (Proxy inteligente para Ollama + Prisma/SQLite).
  - `frontend/`: Dashboard NextJS para monitoramento e gestão de modelos.
- **`scripts/`**: Automação de ambiente.
  - `SETUP.bat`: Orquestrador de script em lote para setup do WSL2 e dependências.

## Tecnologias Principais
- **Blender 3D:** Host principal do Add-on.
- **Ollama:** Engine de inferência local (LLMs).
- **Fastify:** Backend de alto desempenho.
- **NextJS:** Painel de controle web.
- **Prisma + SQLite:** Persistência de dados offline.

Consulte a pasta `docs/` para obter detalhes sobre a implementação de cada componente.
