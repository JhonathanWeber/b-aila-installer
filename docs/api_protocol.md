# Protocolo de Comunicação Blender-Backend

## 1. O Desafio da Thread Única
O Blender opera em uma única thread principal (Main Thread). Se o script Python disparar uma requisição HTTP e ficar esperando, a interface irá congelar.

**Solução:** Usaremos o `bpy.app.timers` para criar um loop de verificação assíncrono que não bloqueia a Viewport.

## 2. O Fluxo de Comunicação (Request-Response Loop)

### Etapa A: O Gatilho (Handshake)
1. O Add-on coleta o Metadata JSON e o Prompt.
2. Envia um POST para o Backend (`:8990/ai/generate`).
3. O Backend responde instantaneamente com um `job_id` e status `processing`.
4. O Blender libera a UI para o usuário imediatamente.

### Etapa B: O Monitoramento (Non-blocking Polling)
1. O Add-on inicia um timer interno (ex: a cada 0.5 segundos).
2. O timer faz um GET leve para `:8990/ai/status/{job_id}`.
3. O Backend consulta o Prisma/SQLite para ver o progresso.

### Etapa C: A Entrega e Execução
1. Assim que o status vira `completed`, o Backend entrega o payload final: `{ "chat": "...", "code": "..." }`.
2. O Blender para o timer e exibe a mensagem.
3. Se o "Auto-Run" estiver ligado, o código é executado em um bloco `try-except`.

## 3. Estrutura do Payload

### Request (Blender -> Backend)
```json
{
"job_id": "uuid",
"prompt": "Crie um terreno",
"context": {
"mode": "OBJECT",
"selection": ["Cube.001"],
"unit_system": "METRIC"
},
"history_session": "sessao_projeto_x"
}
```

### Response (Backend -> Blender)
```json
{
"status": "success",
"data": {
"chat_message": "Aqui está o seu terreno procedural.",
"python_code": "import bpy; ...",
"logs": ["Object 'Terrain' created", "Modifier 'Displace' added"]
}
}
```

## 4. O "Webhook Reverso" (Dashboard)
O Dashboard (NextJS) recebe atualizações via WebSockets ou SSE do Backend, que atua como um Event Bus para logs e métricas de performance.
