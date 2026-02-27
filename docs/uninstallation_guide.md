# Guia de Desinstalação e Limpeza (Fase 5)

Caso deseje remover completamente o ecossistema B-AILA do seu computador, desenvolvemos um script de desinstalação que automatiza esse processo de forma segura e abrangente.

## O Desinstalador: `scripts/uninstall.ps1`

O script `uninstall.ps1` realiza as seguintes ações:

### 1. Encerramento de Processos
- Finaliza o processo do **Ollama** se ele estiver rodando.
- Solicita que o usuário feche os terminais do Backend e Frontend.

### 2. Remoção de Software e Dados
- **Ollama:** Desinstala o Ollama utilizando o Winget.
- **Modelos de IA:** Deleta a pasta `%USERPROFILE%\.ollama`, que contém todos os modelos (LLMs) baixados. **Atenção:** Esta ação é irreversível e liberará vários GBs de espaço em disco.
- **Banco de Dados Local:** Remove o arquivo `dev.db` do SQLite dentro da pasta do backend.

### 3. Limpeza de Rede
- Remove as regras do Firewall do Windows que foram criadas para as portas `8990` e `8991`.

---

## Como Executar
Para desinstalar, abra o PowerShell como Administrador e execute:
```powershell
Set-ExecutionPolicy RemoteSigned -Scope Process
.\scripts\uninstall.ps1
```

## Remoção Manual do Código
O script **não deleta** a pasta contendo o código fonte (`c:/Users/Jhon/workspace/b-aila/`) para evitar a perda acidental de customizações que você possa ter feito. Se desejar remover o código também, basta deletar a pasta manualmente após a execução do script.
