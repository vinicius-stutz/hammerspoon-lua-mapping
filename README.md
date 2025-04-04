# 🔨 Hammerspoon 🌙 LUA mapping
Custom macOS lua scripts for [Hammerspoon](http://www.hammerspoon.org) - mapping keys like Windows/Linux!

[![Hammerspoon](https://img.shields.io/badge/Hammerspoon-Automation-yellow?style=plastic)](https://github.com/Hammerspoon/hammerspoon) [![Lua](https://img.shields.io/badge/Made_with_Lua-2C2D72?style=plastic&logo=lua&logoColor=white)](https://www.lua.org/portugues.html)

Start browsing my code [here (init.lua file)](https://github.com/vinicius-stutz/hammerspoon-lua-mapping/blob/master/init.lua). See more configurations later [here](https://github.com/Hammerspoon/hammerspoon/wiki/Sample-Configurations).

**Note**: The documentation is written in PT-BR because I haven't had time to translate everything I've written yet 🤷🏻‍♂️

## Propósito
Passei a usar macOS após mais de 20 anos entre sistemas operacionais Linux e Windows. Como ainda uso muito Windows em meu dia-a-dia, não me adaptei facilmente às combinações de teclas para atalhos do macOS, então resolvi construir minhas próprias combinações e, de quebra, algumas outras coisas legais com o Hammerspoon. ☺️

Não foi uma questão de certo ou errado, apenas uma questão daquilo que funciona para minha necessidade.

## Estrutura de diretórios adotada

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
--     ├── safari.lua
--     └── mail.lua
```

## Melhorias implementadas
### Organização do código:
- Agrupei os imports em uma tabela hs para facilitar o acesso
- Organizei todas as constantes de teclas em uma tabela KEY
- Criei uma tabela state para gerenciar o estado global do script
- Separei as funções em seções lógicas

### Otimizações de performance:
- Reduzi os delays de teclado ao mínimo (0.01 e 0.10)
- Armazenei a função keyStroke em uma variável local para acesso mais rápido
- Implementei um único evento de monitoramento de teclado em vez de vários
- Otimizei as funções que lidam com eventos de teclado

### Padrões de mercado:
- Usei namespaces consistentes
- Implementei tabelas de funções em vez de condicionais
- Criei funções mais curtas e específicas
- Melhorei o tratamento de erros com pcall

### Combinações de teclas mais rápidas:
- Reduzi os delays entre pressionamentos de tecla
- Otimizei a sequência de teclas no Mail
- Melhorei o sistema de remapeamento de teclas

### Gestão de recursos:
- Limpeza adequada de watchers quando não necessários
- Melhor organização de recursos por aplicativo
- Armazenamento explícito de referências para evitar o garbage collector

As mudanças acima tornaram o meu script do Hammerspoon mais eficiente, com teclas mais responsivas e melhor organizado seguindo padrões de codificação modernos. Ess estrutura também facilita adicionar novas funcionalidades no futuro.

## Benefícios da abordagem modular
- Manutenção mais fácil: Editar apenas o módulo que necessita de modificação;
- Código mais organizado: Cada arquivo tem uma responsabilidade clara;
- Reuso de código: As funções utilitárias são compartilhadas entre diferentes partes;
- Extensibilidade: Suporte para novos aplicativos simplesmente criando um novo arquivo na pasta `apps`;
- Melhor performance: A modularização não afeta o desempenho, pois tudo é carregado na inicialização;
- Facilidade de depuração: Se algo der errado, é mais fácil identificar qual módulo está causando problema.

Esta estrutura modular também facilita compartilhar as configurações ou reutilizá-las em diferentes ambientes, já que cada componente é independente e auto-contido.
