# Documentação do Add-on: Interface e Contexto (Fase 3)

O Add-on do Blender atua como o **Thin Client** do ecossistema B-AILA. Ele é responsável pela interação direta com o artista 3D e pela coleta de dados da Viewport.

## Implementação Técnica: `apps/blender-addon/__init__.py`

### 1. Interface de Usuário (N-Panel)
Criamos uma aba exclusiva chamada **"JhonDev IA"** na barra lateral (N-Key) do Blender.
- **Painel de Chat:** Exibe o histórico de interação (inicialmente um placeholder).
- **Prompt Input:** Campo de texto para comandos do usuário.
- **Auto-Run:** Opção para executar o código Python retornado automaticamente.

### 2. O "Olhar" da IA (Metadata Snapshot)
A função `get_scene_snapshot` extrai informações estruturadas da cena atual sem sobrecarregar o processamento:
- Objetos selecionados, seus tipos (Mesh, Camera, etc.) e localizações.
- Modo atual (Object, Edit, Sculpt).
- Sistema de unidades (Métrico/Imperial).

### 3. Comunicação Assíncrona (Non-blocking)
Para evitar que o Blender congele enquanto a IA processa o prompt (que pode levar segundos), implementamos um sistema de **Polling Assíncrono**:
- O Add-on envia o prompt e recebe um `job_id` instantaneamente.
- Utilizamos `bpy.app.timers` para verificar o status do servidor a cada 1 segundo em segundo plano.
- Quando o status muda para `completed`, a resposta é processada e exibida.

---

## Próximos Passos
Na próxima etapa da Fase 3, focaremos na **Camada de Execução com Self-Healing**, permitindo que o Add-on capture erros de execução do Python gerado e solicite correções automáticas ao backend.
