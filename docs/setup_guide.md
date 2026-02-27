# Documentação de Infraestrutura e Setup (Fase 1)

Esta fase foca na automação da preparação do ambiente Windows para suportar o ecossistema B-AILA.

## O Orquestrador: `scripts/install.ps1`

O script `install.ps1` foi desenvolvido em PowerShell para transformar uma configuração complexa em uma experiência de poucos cliques. Abaixo estão os detalhes do que ele realiza:

### 1. Gestão de Privilégios
O script detecta automaticamente se está sendo executado como Administrador. Caso contrário, ele solicita a elevação de privilégios via `RunAs`, evitando que o usuário precise fazer isso manualmente.

### 2. Verificações Pré-Voo (Pre-flight Checks)
Antes de iniciar qualquer instalação, o script valida:
- **Virtualização:** Verifica se VT-x ou AMD-V está habilitado na BIOS (necessário para o WSL2).
- **Espaço em Disco:** Garante que existam pelo menos 20GB livres para acomodar o subsistema Linux e os modelos de IA.

### 3. Instalação de Dependências
- **Winget:** Utiliza o gerenciador de pacotes nativo do Windows para baixar e instalar o **Ollama**.
- **WSL2:** Verifica o status do Windows Subsystem for Linux e executa `wsl --install` se necessário.

### 4. Configuração de Rede
Cria automaticamente regras no Firewall do Windows para permitir o tráfego nas portas:
- `8990` (Backend B-AILA)
- `8991` (Dashboard NextJS)

---

## Como Executar

O B-AILA oferece um ponto de entrada simplificado na raiz do projeto:

1. Localize o arquivo `SETUP.bat`.
2. Dê um duplo clique ou execute via terminal:
```cmd
.\SETUP.bat
```

Este arquivo disparará automaticamente o script `install.ps1` com as permissões de execução corretas.

### 5. Inicialização Automática
Após a configuração da infraestrutura, o instalador agora **inicia automaticamente** os serviços necessários:
- Uma nova janela do terminal abrirá para o **Backend**.
- Uma nova janela do terminal abrirá para o **Frontend (Dashboard)**.
- O seu **navegador padrão** será aberto automaticamente em `http://localhost:8991`.

Isso significa que você só precisa rodar o `SETUP.bat` e já pode abrir o Blender para começar a criar.

## Próximos Passos
Com os serviços rodando, abra o Blender e utilize o painel **JhonDev IA** para interagir com a inteligência artificial local.
