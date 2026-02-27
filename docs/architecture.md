# Documentação Técnica: Projeto B-AILA (Blender AI Local Assistant)

## 1. Visão Geral
O objetivo é criar um Add-on para Blender que funcione como um copiloto em tempo real. Ele deve ser capaz de conversar via chat, entender o contexto da Viewport 3D, salvar o histórico de interações e executar comandos Python (bpy) para automatizar a modelagem e cena.

## 2. Decisões de Arquitetura (Local-First)

### A. Engine de Inferência (O "Cérebro")
- **Tecnologia:** Ollama rodando nativamente no Windows ou via Docker Desktop (WSL2).
- **Modelo Sugerido:** Codellama (para geração de código precisa) ou Llama3:8b (para conversação geral).
- **Comunicação:** O Blender enviará requisições HTTP POST para `http://localhost:11434/api/generate`.

### B. Interface do Usuário (UI/UX)
- **Localização:** Aba lateral da Viewport 3D (N-Panel), sob a categoria "JhonDev IA".
- **Componentes:**
    - **Área de Chat:** Um UIList dinâmico para exibir o histórico da conversa.
    - **Campo de Entrada:** StringProperty para o prompt do usuário.
    - **Botão de Ação:** Gatilho para processar o prompt e executar o código retornado.

### C. Sistema de Contexto (O "Olhar" da IA)
Para a IA entender o que está acontecendo sem precisar de processamento de imagem pesado inicialmente, usaremos Injeção de Metadados:
- **Scene Snapshot:** Antes de enviar o prompt, o script gera um resumo em texto (JSON) contendo:
    - Lista de objetos selecionados.
    - Tipo de cada objeto (Mesh, Light, Camera).
    - Modo atual (Object Mode, Edit Mode, Sculpt).
    - Materiais ativos.

### D. Persistência de Dados (Memória)
- **Armazenamento:** Arquivo SQLite local ou JSON dentro da pasta do projeto.
- **Estrutura:** Salvaremos o par Prompt : Resposta e o Scene_Context daquele momento. Isso permite que a IA saiba o que foi feito em etapas anteriores.

## 3. Fluxo de Execução (O Loop de Feedback)
1. **Input:** Usuário digita: "Crie uma escada em espiral com 20 degraus".
2. **Contextualização:** O Add-on lê que você está no modo "Object" e que a unidade de medida é "Metros".
3. **Request:** O script envia o System Prompt (Regras do Blender) + Contexto da Cena + Prompt do Usuário para o Ollama.
4. **Parsing:** O Add-on recebe a resposta, extrai apenas o bloco de código Python e ignora explicações textuais.
5. **Execution:** O código é rodado via `exec(code_string)` dentro do contexto do Blender.
6. **Log:** A conversa é salva no histórico local e exibida no painel de chat.

## 4. Considerações de Segurança e Performance
- **Isolamento:** Uso de WSL2 para o backend da IA para não interferir na performance de renderização.
- **Sanitização:** Validação de comandos perigosos antes da execução.
