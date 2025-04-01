-- init.lua: Arquivo principal que carrega todos os módulos

-- Carregar configurações globais
local config = require("config")

-- Carregar bibliotecas utilitárias
local keyboard = require("lib.keyboard")
local window = require("lib.window")

-- Carregar configurações específicas de aplicativos
local finderConfig = require("apps.finder")
local safariConfig = require("apps.safari")
local mailConfig = require("apps.mail")

-- Estado global compartilhado entre módulos
local state = {
    appWatcher = nil,
    isRenaming = false,
    keyboardWatcher = nil,
    safariHotkeys = {},
    appleMailHotkeys = {}
}

-- Função para monitorar aplicativos
local function applicationWatcher(appName, eventType, app)
    if appName == "Finder" then
        finderConfig.handleFinderEvents(appName, eventType, app, state)
    elseif appName == "Safari" then
        safariConfig.handleSafariEvents(appName, eventType, app, state)
    elseif appName == "Mail" then
        mailConfig.handleMailEvents(appName, eventType, app, state)
    end
end

-- Inicialização do sistema
local function init()
    -- Limpar console
    hs.console.clearConsole()
    
    -- Configurar performance
    keyboard.setupPerformanceSettings()
    
    -- Criar atalhos de teclado
    keyboard.createShortcuts()
    
    -- Configurar atalhos de janela
    window.setupWindowBindings()
    
    -- Iniciar watcher de aplicativos
    state.appWatcher = hs.application.watcher.new(applicationWatcher)
    state.appWatcher:start()
    
    -- Iniciar watcher de teclas Ctrl+setas
    keyboard.setupCtrlArrowWatcher()
    
    -- Notificar inicialização
    hs.alert.show("Seja bem-vindo(a), " .. config.userName .. "!\nSeus scripts Hammerspoon foram carregados com sucesso!",
    {
        strokeWidth  = 0.12,
        strokeColor = { white = 1, alpha = 1 },
        fillColor   = { white = 0.12, alpha = 0.8 },
        textColor = { white = 1, alpha = 1 },
        textFont  = ".AppleSystemUIFont",
        textSize  = 13,
        radius = 6,
        atScreenEdge = 0,
        fadeInDuration = 0.15,
        fadeOutDuration = 0.15,
        padding = 16,
    }, 6)
end

-- Iniciar o sistema
init()

-- Armazenar referências globais para evitar coleta pelo garbage collector
_G.state = state