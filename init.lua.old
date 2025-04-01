-- Imports e usings - agrupados e otimizados
local hs = {
    hotkey = require("hs.hotkey"),
    eventtap = require("hs.eventtap"),
    application = require("hs.application"),
    window = require("hs.window"),
    alert = require("hs.alert"),
    mouse = require("hs.mouse"),
    ax = require("hs.axuielement"),
    execute = hs.execute,
    console = require("hs.console")
}

-- Namespace mais curto para eventos
local types = hs.eventtap.event.types

-- Constantes para códigos de teclas - agrupadas em uma tabela
local KEY = {
    LEFT = 123,
    RIGHT = 124,
    UP = 126,
    DOWN = 125,
    ESC = 53,
    ENTER = 36,
    F2 = 120,
    HOME = 115,
    END = 119,
    FORWARD_DELETE = 117
}

-- Mapeamento de teclas para nomes mais eficiente
local keyMapping = {
    [KEY.LEFT] = "left",
    [KEY.RIGHT] = "right",
    [KEY.UP] = "up",
    [KEY.DOWN] = "down"
}

-- Variáveis de estado
local state = {
    isRenaming = false,
    keyboardWatcher = nil,
    safariHotkeys = {},
    appleMailHotkeys = {},
    keyboardEventDelay = 0, -- Mínimo delay possível
    appWatcher = nil,
    ctrlArrowWatcher = nil
}

-- Cache de funções usadas frequentemente para melhorar performance
local fastKeyStroke = hs.eventtap.keyStroke

-- Configurações de janelas
local windowBindings = {
    { {"alt"}, "left", "half-left" },
    { {"alt"}, "right", "half-right" },
    { {"alt"}, "up", "maximize" },
    { {"alt"}, "down", "minimize" },
    { {"alt", "cmd"}, "left", "move-left" },
    { {"alt", "cmd"}, "right", "move-right" }
}

-- Limpar console
hs.console.clearConsole()

-- FUNÇÕES PRINCIPAIS

-- Função otimizada para movimentar janelas
local function moveWindow(action)
    local win = hs.window.focusedWindow()
    if not win then return end
    
    local screen = win:screen()
    local frame = screen:frame()
    
    -- Usando tabela de funções em vez de condicionais
    local actions = {
        ["half-left"] = function() 
            win:setFrame({x = frame.x, y = frame.y, w = frame.w / 2, h = frame.h})
        end,
        ["half-right"] = function() 
            win:setFrame({x = frame.x + frame.w / 2, y = frame.y, w = frame.w / 2, h = frame.h})
        end,
        ["maximize"] = function() 
            win:maximize() 
        end,
        ["minimize"] = function() 
            win:minimize() 
        end,
        ["move-left"] = function() 
            if screen:toWest() then win:moveToScreen(screen:toWest()) end 
        end,
        ["move-right"] = function() 
            if screen:toEast() then win:moveToScreen(screen:toEast()) end 
        end
    }
    
    -- Executa a ação diretamente se existir
    if actions[action] then actions[action]() end
end

-- Função para criar atalhos de forma mais eficiente
local function createShortcuts()
    -- Atalhos a desabilitar (prevenção de acidentes)
    local disableKeys = {
        {{"cmd"}, "q"}, -- Evita fechar acidentalmente
        {{"cmd"}, "w"}  -- Evita fechar aba acidentalmente
    }

    -- Remapeamento de Ctrl para Cmd (padrão Windows -> Mac)
    local ctrlToCmd = {
        "z", "x", "v", "c", "o", "s", "f", "a", "p", "l", "t"
    }

    -- Casos especiais de mapeamento
    local specialCases = {
        {{"ctrl"}, "y", {"cmd", "shift"}, "z"},          -- Refazer
        {{"ctrl", "shift"}, "t", {"cmd", "shift"}, "t"}, -- Restaurar aba
        {{"alt"}, "l", {"cmd", "ctrl"}, "q"},            -- Bloquear tela
        {{"ctrl"}, "d", {"cmd", "shift"}, "d"},          -- Duplicar linha
        {{"ctrl", "shift"}, "v", {"cmd", "shift"}, "v"}  -- Colar sem formatação
    }

    -- Navegação (códigos de tecla -> atalhos Mac)
    local navigationKeys = {
        {KEY.HOME, {"cmd"}, KEY.LEFT},                              -- Home -> Início da linha
        {{"shift"}, KEY.HOME, {"cmd", "shift"}, KEY.LEFT},          -- Shift+Home -> Selecionar até início
        {KEY.END, {"cmd"}, KEY.RIGHT},                              -- End -> Fim da linha
        {{"shift"}, KEY.END, {"cmd", "shift"}, KEY.RIGHT},          -- Shift+End -> Selecionar até fim
        {{"ctrl"}, KEY.HOME, {"cmd"}, KEY.UP},                      -- Ctrl+Home -> Topo do documento
        {{"ctrl"}, KEY.END, {"cmd"}, KEY.DOWN},                     -- Ctrl+End -> Final do documento
        {{"ctrl", "shift"}, KEY.HOME, {"cmd", "shift"}, KEY.UP},    -- Ctrl+Shift+Home -> Selecionar até topo
        {{"ctrl", "shift"}, KEY.END, {"cmd", "shift"}, KEY.DOWN}    -- Ctrl+Shift+End -> Selecionar até final
    }

    -- 1. Desabilitar teclas perigosas
    for _, key in ipairs(disableKeys) do 
        hs.hotkey.bind(key[1], key[2], nil, function() return true end)
    end

    -- 2. Remapear Ctrl para Cmd (atalhos Windows->Mac)
    for _, key in ipairs(ctrlToCmd) do 
        hs.hotkey.bind({"ctrl"}, key, nil, function() 
            fastKeyStroke({"cmd"}, key, state.keyboardEventDelay) 
        end)
    end

    -- 3. Casos especiais
    for _, map in ipairs(specialCases) do 
        hs.hotkey.bind(map[1], map[2], nil, function() 
            fastKeyStroke(map[3], map[4], state.keyboardEventDelay) 
        end)
    end

    -- 4. Teclas de navegação
    for _, nav in ipairs(navigationKeys) do
        if type(nav[1]) == "table" then
            -- Com modificadores (ex: shift)
            hs.hotkey.bind(nav[1], nav[2], nil, function() 
                fastKeyStroke(nav[3], nav[4], state.keyboardEventDelay) 
            end)
        else
            -- Sem modificadores adicionais
            hs.hotkey.bind({}, nav[1], nil, function() 
                fastKeyStroke(nav[2], nav[3], state.keyboardEventDelay) 
            end)
        end
    end
end

-- Configurações para melhorar performance
local function setupPerformanceSettings()
    -- Reduzir delays ao mínimo
    hs.eventtap.keyRepeatInterval(0.01) -- Menor intervalo de repetição
    hs.eventtap.keyRepeatDelay(0.10)    -- Menor delay inicial

    -- Criar um único tap para eventos de teclado
    state.keyTap = hs.eventtap.new({types.keyDown, types.keyUp}, function(event)
        -- Implementação conforme necessidade
        return false -- Por padrão, não consome o evento
    end)
    
    -- Ativar o tap
    state.keyTap:start()
end

-- Gerenciador de eventos por aplicação
local function applicationWatcher(appName, eventType, app)
    -- Gerenciar atalhos no Finder
    if appName == "Finder" then
        if eventType == hs.application.watcher.activated then
            -- Criar watcher apenas se não existir
            if not state.keyboardWatcher then
                state.keyboardWatcher = hs.eventtap.new({types.keyDown}, function(event)
                    local keyCode = event:getKeyCode()

                    if keyCode == KEY.F2 then -- F2 (Renomear)
                        state.isRenaming = true
                        app:selectMenuItem({"Arquivo", "Renomear"})
                        return true
                    elseif keyCode == KEY.ENTER then -- Enter
                        if not state.isRenaming then
                            fastKeyStroke({"cmd"}, "o", state.keyboardEventDelay)
                            return true
                        else
                            state.isRenaming = false
                        end
                    elseif keyCode == KEY.FORWARD_DELETE then -- Delete
                        if not state.isRenaming then
                            fastKeyStroke({"cmd"}, "delete", state.keyboardEventDelay)
                            return true
                        end
                    end
                    return false
                end)
                state.keyboardWatcher:start()
            end
        elseif eventType == hs.application.watcher.deactivated then
            -- Limpar recursos quando o Finder não está ativo
            if state.keyboardWatcher then
                state.keyboardWatcher:stop()
                state.keyboardWatcher = nil
            end
            state.isRenaming = false
        end
    end

    -- Atalhos para Mail
    if appName == "Mail" then
        if eventType == hs.application.watcher.activated then
            state.appleMailHotkeys = {
                hs.hotkey.bind({"ctrl"}, "m", function()
                    app:selectMenuItem({"Mensagem", "Mover para"})
                    -- Sequência otimizada de teclas
                    local navigations = {
                        {"", "m"}, {"", "m"}, {"", "m"}, 
                        {"", "right"}, 
                        {"", "down"}, {"", "down"}, {"", "down"}, 
                        {"", "down"}, {"", "down"}, {"", "down"}
                    }
                    
                    -- Executa sequência com pequeno intervalo
                    for _, key in ipairs(navigations) do
                        fastKeyStroke(key[1], key[2], 0.2)
                    end
                end),
                
                hs.hotkey.bind({"ctrl"}, "space", function()
                    fastKeyStroke({"shift", "cmd"}, "u", state.keyboardEventDelay)
                end)
            }
        elseif eventType == hs.application.watcher.deactivated then
            -- Limpar hotkeys do Mail
            if state.appleMailHotkeys then
                for _, hotkey in pairs(state.appleMailHotkeys) do
                    if hotkey and type(hotkey.delete) == "function" then
                        pcall(function() hotkey:delete() end)
                    end
                end
                state.appleMailHotkeys = {}
            end
        end
    end

    -- Atalhos para Safari
    if appName == "Safari" then
        if eventType == hs.application.watcher.activated then
            if not state.safariHotkeys or #state.safariHotkeys == 0 then
                state.safariHotkeys = {
                    -- Atalhos de tradução
                    hs.hotkey.bind({"cmd", "shift"}, "p", function()
                        app:selectMenuItem({"Visualizar", "Tradução", "Traduzir para Português"})
                        hs.alert.show("Tradução PT-BR em andamento…", 1)
                    end),
                    
                    hs.hotkey.bind({"cmd", "shift"}, "t", function()
                        app:selectMenuItem({"Visualizar", "Tradução", "Ver Original"})
                        hs.alert.show("Voltando ao idioma original…", 1)
                    end),
                    
                    -- Atalhos de desenvolvedor
                    hs.hotkey.bind({"ctrl"}, "u", function()
                        fastKeyStroke({"alt", "cmd"}, "u", state.keyboardEventDelay)
                    end),
                    
                    hs.hotkey.bind({"ctrl", "shift"}, "i", function()
                        fastKeyStroke({"alt", "cmd"}, "i", state.keyboardEventDelay)
                    end),
                    
                    hs.hotkey.bind({}, "f12", function()
                        fastKeyStroke({"alt", "cmd"}, "c", state.keyboardEventDelay)
                    end),
                    
                    -- Atalhos de atualização
                    hs.hotkey.bind({}, "f5", function()
                        fastKeyStroke({"cmd"}, "r", state.keyboardEventDelay)
                    end),
                    
                    hs.hotkey.bind({"ctrl"}, "r", function()
                        fastKeyStroke({"cmd"}, "r", state.keyboardEventDelay)
                    end),
                    
                    -- Atualização forçada (limpa cache)
                    hs.hotkey.bind({"ctrl"}, "f5", function()
                        fastKeyStroke({"alt", "cmd"}, "e", state.keyboardEventDelay)
                        fastKeyStroke({"cmd"}, "r", state.keyboardEventDelay)
                    end),
                    
                    hs.hotkey.bind({"ctrl", "shift"}, "r", function()
                        fastKeyStroke({"alt", "cmd"}, "e", state.keyboardEventDelay)
                        fastKeyStroke({"cmd"}, "r", state.keyboardEventDelay)
                    end)
                }
            end
        elseif eventType == hs.application.watcher.deactivated then
            -- Limpar hotkeys do Safari
            if state.safariHotkeys then
                for _, hotkey in pairs(state.safariHotkeys) do
                    if hotkey and type(hotkey.delete) == "function" then
                        pcall(function() hotkey:delete() end)
                    end
                end
                state.safariHotkeys = {}
            end
        end
    end
end

-- Função para focar na barra de menu
local function focusOnMenuBarUI()
    local currentApp = hs.application.frontmostApplication()
    
    if currentApp then
        local menuItems = currentApp:getMenuItems()
        if menuItems and #menuItems > 0 then
            currentApp:selectMenuItem({menuItems[1].AXTitle})
            return true
        end
    end
    
    return false
end

-- INICIALIZAÇÃO DO SCRIPT

-- 1. Configurar atalhos para comandos principais
hs.hotkey.bind({"cmd"}, "f4", nil, function()
    local app = hs.application.frontmostApplication()
    if app then app:kill() end
end)

hs.hotkey.bind({"ctrl"}, "f4", nil, function()
    local win = hs.window.focusedWindow()
    if win then win:close() end
end)

hs.hotkey.bind({"alt"}, "d", nil, function()
    local allWindows = hs.window.visibleWindows()
    for _, win in ipairs(allWindows) do
        win:minimize()
    end
    hs.alert.show("Mostrar área de trabalho", 1)
end)

-- 2. Atalhos de sistema
hs.hotkey.bind({"alt"}, "tab", function() 
    hs.execute("open -a 'Mission Control'") 
end)

hs.hotkey.bind({"ctrl"}, KEY.ESC, function() 
    hs.execute("open -a 'Launchpad'") 
end)

hs.hotkey.bind({"ctrl", "shift"}, KEY.ESC, function() 
    hs.execute("open -a 'Activity Monitor.app'") 
end)

hs.hotkey.bind({"alt"}, "f", function() 
    hs.execute("open -a 'Finder.app'") 
end)

-- 3. Atalho para menu principal
hs.hotkey.bind({"alt"}, "space", focusOnMenuBarUI)

-- 4. Configurar o watcher para Ctrl+setas
state.ctrlArrowWatcher = hs.eventtap.new({types.keyDown}, function(event)
    local keyCode = event:getKeyCode()
    local flags = event:getFlags()
    
    -- Verifica se a tecla é uma seta (esquerda ou direita)
    if (keyCode == KEY.LEFT or keyCode == KEY.RIGHT) and flags.ctrl then
        -- Prepara novos modificadores
        local newModifiers = {"alt"}
        if flags.shift then table.insert(newModifiers, "shift") end
        
        -- Simula pressionamento mais rápido
        fastKeyStroke(newModifiers, keyMapping[keyCode], 0)
        return true
    end
    
    return false
end)

-- 5. Configurar atalhos para janelas
for _, bind in ipairs(windowBindings) do 
    hs.hotkey.bind(bind[1], bind[2], nil, function() 
        moveWindow(bind[3]) 
    end) 
end

-- 6. Inicializar componentes principais
createShortcuts()
setupPerformanceSettings()

-- 7. Iniciar monitores de aplicações
state.appWatcher = hs.application.watcher.new(applicationWatcher)
state.appWatcher:start()
state.ctrlArrowWatcher:start()

-- Armazenar referências globais para evitar coleta pelo garbage collector
_G.state = state
