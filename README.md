# Hammerspoon LUA mapping

Custom macOS 🌙 lua scripts for 🔨 [Hammerspoon](http://www.hammerspoon.org) - mapping keys like Windows/Linux!

[![macOS](https://img.shields.io/badge/Apple_macOS-222222?logo=apple&logoColor=white)](https://www.lua.org/portugues.html) [![Hammerspoon](https://img.shields.io/badge/Hammerspoon-Automation-yellow)](https://github.com/Hammerspoon/hammerspoon) [![Lua](https://img.shields.io/badge/Made_with-Lua-2C2D72?logo=lua&logoColor=white)](https://www.lua.org/portugues.html)

Start browsing my code [here (init.lua file)](https://github.com/vinicius-stutz/hammerspoon-lua-mapping/blob/master/init.lua). See more configurations later [here](https://github.com/Hammerspoon/hammerspoon/wiki/Sample-Configurations).

**Note**: The documentation is written in PT-BR because I haven't had time to translate everything I've written yet 🤷🏻‍♂️

- [Hammerspoon LUA mapping](#hammerspoon-lua-mapping)
  - [1. Propósito](#1-propósito)
    - [1.1. Pré-requisitos](#11-pré-requisitos)
    - [1.2. Outros mapeamentos](#12-outros-mapeamentos)
  - [2. Estrutura de diretórios adotada](#2-estrutura-de-diretórios-adotada)
  - [3. Melhorias implementadas](#3-melhorias-implementadas)
    - [3.1. Organização do código:](#31-organização-do-código)
    - [3.2. Otimizações de performance:](#32-otimizações-de-performance)
    - [3.3. Padrões de mercado:](#33-padrões-de-mercado)
    - [3.4. Combinações de teclas mais rápidas:](#34-combinações-de-teclas-mais-rápidas)
    - [3.5. Gestão de recursos:](#35-gestão-de-recursos)
  - [4. Benefícios da abordagem modular](#4-benefícios-da-abordagem-modular)

## 1. Propósito

Passei a usar macOS após mais de 20 anos entre sistemas operacionais Linux e Windows. Como ainda uso muito Windows em meu dia-a-dia, não me adaptei facilmente às combinações de teclas para atalhos do macOS, então resolvi construir minhas próprias combinações e, de quebra, algumas outras coisas legais com o _Hammerspoon_. ☺️

> **Nota**: Não que seja uma questão de certo ou errado, apenas uma questão daquilo que funciona para minha (e de repente até a sua) necessidade.

### 1.1. Pré-requisitos

Com a finalidade de evitar muitos remapeamentos, sugiro seguir os seguintes passos antes de colocar estes scripts para funcionar em sua instância do _Hammerspoon_:

1. Abrir os Ajustes do Sistema;
2. Teclado;
3. Clicar em "Atalhos de Teclado…";
4. Teclas Modificadoras;
5. Selecione o seu teclado preferido e troque:
   a. Tecla Control (^) => ⌘ Command;
   b. Tecla Option (⌥) => ^ Control;
   c. Tecla Command (⌘) => ⌥ Option.

Desta forma:

- Control funciona como a tecla Control do Windows/Linux;
- Option funciona como a tecla WIN do Windows;
- Command funciona como a tecla ALT do Windows/Linux.

### 1.2. Outros mapeamentos

Mapeamentos por fora do _Hammerspoon_ (apenas dicas):

- AltTab.app => ⌥+TAB
- Ajustes do Sistema (primeiro desative todos os atalhos e depois…)
  - Mostrar Launchpad => ^+Espaço
  - Mission Control => ^+TAB
  - Janelas do aplicativo => ^+Shift+TAB
  - Mover o foco para o Dock => ⌘+ESC
  - Atalhos de Apps
    - Todos os Aplicativos
      - Mostrar menu de Ajuda => F1
      - Help => F1

## 2. Estrutura de diretórios adotada

```
-- ~/.hammerspoon/
-- ├── init.lua                   (arquivo principal - carrega os módulos)
-- ├── config.lua                 (configurações globais)
-- ├── lib/                       (funções utilitárias)
-- │   ├── keyboard.lua           (funções de teclado)
-- │   ├── mouse.lua              (funções do mouse)
-- │   └── window.lua             (funções de janela)
-- └── apps/                      (configurações específicas de apps)
--     ├── finder.lua
--     ├── ide.lua
--     ├── safari.lua
--     └── mail.lua
```

## 3. Melhorias implementadas

### 3.1. Organização do código:

- Agrupei os imports em uma tabela hs para facilitar o acesso
- Organizei todas as constantes de teclas em uma tabela KEY
- Criei uma tabela state para gerenciar o estado global do script
- Separei as funções em seções lógicas

### 3.2. Otimizações de performance:

- Reduzi os delays de teclado ao mínimo (0.01 e 0.10)
- Armazenei a função keyStroke em uma variável local para acesso mais rápido
- Implementei um único evento de monitoramento de teclado em vez de vários
- Otimizei as funções que lidam com eventos de teclado

### 3.3. Padrões de mercado:

- Usei namespaces consistentes
- Implementei tabelas de funções em vez de condicionais
- Criei funções mais curtas e específicas
- Melhorei o tratamento de erros com pcall

### 3.4. Combinações de teclas mais rápidas:

- Reduzi os delays entre pressionamentos de tecla
- Otimizei a sequência de teclas no Mail
- Melhorei o sistema de remapeamento de teclas

### 3.5. Gestão de recursos:

- Limpeza adequada de watchers quando não necessários
- Melhor organização de recursos por aplicativo
- Armazenamento explícito de referências para evitar o garbage collector

As mudanças acima tornaram o meu script do Hammerspoon mais eficiente, com teclas mais responsivas e melhor organizado seguindo padrões de codificação modernos. Ess estrutura também facilita adicionar novas funcionalidades no futuro.

## 4. Benefícios da abordagem modular

- Manutenção mais fácil: Editar apenas o módulo que necessita de modificação;
- Código mais organizado: Cada arquivo tem uma responsabilidade clara;
- Reuso de código: As funções utilitárias são compartilhadas entre diferentes partes;
- Extensibilidade: Suporte para novos aplicativos simplesmente criando um novo arquivo na pasta `apps`;
- Melhor performance: A modularização não afeta o desempenho, pois tudo é carregado na inicialização;
- Facilidade de depuração: Se algo der errado, é mais fácil identificar qual módulo está causando problema.

Esta estrutura modular também facilita compartilhar as configurações ou reutilizá-las em diferentes ambientes, já que cada componente é independente e auto-contido.

---

![VSCode](https://img.shields.io/badge/Feito_com_❤️_usando_o-VS_Code-007ACC)
