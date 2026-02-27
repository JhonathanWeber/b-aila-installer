# Manual do Usuário: B-AILA

Bem-vindo ao **B-AILA (Blender AI Local Assistant)**! Este guia ajudará você a entender como utilizar o seu novo copiloto de modelagem 3D.

## 1. Visão Geral
O B-AILA é uma ferramenta **Open Source** projetada para rodar inteiramente no seu hardware local, garantindo privacidade e velocidade. Ele conecta o Blender a modelos de linguagem (LLMs) via Ollama.

## 2. Primeiros Passos
Para começar, certifique-se de que seguiu o guia de instalação:
1. Execute o `install.ps1` para configurar o ambiente.
2. Inicie o Backend (`apps/backend`) e o Dashboard (`apps/frontend`).
3. Instale o Add-on no Blender (`apps/blender-addon/__init__.py`).

## 3. Como Interagir com a IA
No painel **JhonDev IA** dentro do Blender:
- **Snapshot da Cena:** O B-AILA envia automaticamente o que você selecionou e o modo atual para a IA.
- **Prompts Eficazes:** Tente ser específico. Ex: *"Crie uma mesa de madeira com 4 pernas cilíndricas"* funciona melhor do que *"Faça uma mesa"*.
- **Auto-Run:** Se ativado, o código gerado será executado assim que chegar. Use com cautela!

## 4. O Sistema de Auto-Correção (Self-Healing)
Se a IA gerar um código com erro de sintaxe, o Blender capturará esse erro e enviará de volta ao sistema. Você pode ver esses logs detalhados aqui no Dashboard.

## 5. Contribuição (Open Source)
Sendo um projeto aberto, encorajamos você a:
- Sugerir novas funcionalidades.
- Reportar bugs através dos logs do Dashboard.
- Contribuir com código para o Add-on ou Backend.

---
*B-AILA - Transformando prompts em geometria.*
