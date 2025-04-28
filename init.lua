--[[
--Copyright (c) 2025 vinici.us.com. All Rights Reserved.
--Licensed under the MIT license.
--]]

-- init.lua: Arquivo principal que carrega todos os módulos

hs.console.clearConsole() -- Limpar console
print("")
print("-- Iniciando Hammerspoon…")
print("")
print("-- ----------------------------------------------------------------")
print("-- Obrigado por usar meus scripts customizados para o Hammerspoon!")
print("-- Para maiores detalhes, acesse https://vinici.us.com")
print("-- ----------------------------------------------------------------")
print("")

-- Carregar configurações globais
print("-- Carregando módulo de configuração…")
local config = require("config")

-- Carregar bibliotecas utilitárias
print("-- Carregando módulo de atalhos de teclado do S.O.…")
local keyboard = require("lib.keyboard")

print("-- Carregando módulo de controle de janelas…")
local window = require("lib.window")

-- Descomente as linhas abaixo caso não use CMD no lugar de CTRL nas configurações
--print("-- Carregando módulo de controle do mouse…")
--local mouse = require("lib.mouse")

-- Carregar configurações específicas de aplicativos
print("-- Carregando módulo do Finder…")
local finder = require("apps.finder")

print("-- Carregando módulo do Safari…")
local safari = require("apps.safari")

print("-- Carregando módulo do Apple Mail…")
local mail = require("apps.mail")

print("-- Carregando módulo das IDEs…")
local ide = require("apps.ide")

-- Estado global compartilhado entre módulos
local state = {
    appWatcher = nil,
    isRenaming = false,
    keyboardWatcher = nil,
    safariHotkeys = {},
    appleMailHotkeys = {},
    idesHotkeys = {},
}

-- Função para monitorar aplicativos
local function applicationWatcher(appName, eventType, app)
    if appName == "Finder" then
        finder.handleEvents(appName, eventType, app, state)
    elseif appName == "Safari" then
        safari.handleEvents(appName, eventType, app, state)
    elseif appName == "Mail" then
        mail.handleEvents(appName, eventType, app, state)
    elseif appName == "Code" or appName == "Rider" then
        ide.handleEvents(appName, eventType, app, state)
    end
end

-- Inicialização do sistema
local function init()
    print("-- Otimizando performance da aplicação…")
    keyboard.setupPerformanceSettings()

    print("-- Criando atalhos de teclado para o sistema operacional…")
    keyboard.createShortcuts()
    keyboard.createNavigationsShortcuts()

    print("-- Iniciando watcher de teclas CTRL+Setas…")
    keyboard.setupCtrlArrowWatcher()

    print("-- Configurando atalhos de janela…")
    window.setupWindowBindings()

    print("-- Configurando uso do CTRL+TAB nas aplicações com abas…")
    window.setupCtrlTab()

    -- Descomente as linha abaixo caso não use CMD no lugar de CTRL nas configurações
    --print("-- Iniciando o swapper automaticamente quando o módulo de mouse é carregado…")
    --mouse.startModifierSwap()

    print("-- Iniciando watcher de aplicativos…")
    state.appWatcher = hs.application.watcher.new(applicationWatcher)
    state.appWatcher:start()

    -- Notificar inicialização
    hs.alert.show
    (
        "Seja bem-vindo(a), " .. config.userName .. "!\nSeus scripts Hammerspoon foram carregados com sucesso!",
        config.AlertStyle,
        6
    )

    print("-- Configuração de atalhos concluída!")
    print("")
    print("-- LEMBRE-SE:")
    print("-- Para o correto funcionamento, é necessário trocar as teclas CMD, OPT e CTRL nos Ajustes do Sistema!")
end

-- Iniciar o sistema
init()

-- Armazenar referências globais para evitar coleta pelo garbage collector
_G.state = state
