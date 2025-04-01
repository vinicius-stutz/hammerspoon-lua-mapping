-- variáveis globais
local hotkey = require("hs.hotkey")
local eventtap = require("hs.eventtap")
local application = require("hs.application")
local console = require("hs.console")
local window = require("hs.window")
local alert = require("hs.alert")
local mouse = require("hs.mouse")
local events = eventtap.event.types

local isRenaming = false
local keyboardWatcher = nil
local safariHotkeys = {}
local appleMailHotkeys = {}
local keyboardEventDelay = 0 -- Diminui o delay padrão

-- Mapeamento de atalhos para movimentação e redimensionamento de janelas
local windowBindings = {
    { {"alt"}, "left", "half-left" },
    { {"alt"}, "right", "half-right" },
    { {"alt"}, "up", "maximize" },
    { {"alt"}, "down", "minimize" },
    { {"alt", "cmd"}, "left", "move-left" },
    { {"alt", "cmd"}, "right", "move-right" }
}

console.clearConsole() -- limpa o console

-- Função para movimentar e redimensionar janelas
local function moveWindow(action)
    local win = window.focusedWindow()
    if not win then return end
    local screen = win:screen()
    local frame = screen:frame()
    local actions = {
        ["half-left"]   = function() win:setFrame({x = frame.x, y = frame.y, w = frame.w / 2, h = frame.h}) end,
        ["half-right"]  = function() win:setFrame({x = frame.x + frame.w / 2, y = frame.y, w = frame.w / 2, h = frame.h}) end,
        ["maximize"]    = function() win:maximize() end,
        ["minimize"]    = function() win:minimize() end,
        ["move-left"]   = function() if screen:toWest() then win:moveToScreen(screen:toWest()) end end,
        ["move-right"]  = function() if screen:toEast() then win:moveToScreen(screen:toEast()) end end
    }
    if actions[action] then actions[action]() end
end

-- Fechar aplicação
hotkey.bind({"cmd"}, "f4", nil, function()
    local app = application.frontmostApplication()
    if app then app:kill() end
end)

-- Fechar aba
hotkey.bind({"ctrl"}, "f4", nil, function()
    local win = window.focusedWindow()
    if win then win:close() end
end)

-- Mostrar desktop
hotkey.bind({"alt"}, "d", nil, function()
    local allWindows = window.visibleWindows()
    for _, win in ipairs(allWindows) do
        win:minimize()
    end
    alert.show("Mostrar área de trabalho")
end)

-- Nativos do macOS
hotkey.bind({"alt"}, "tab", function() hs.execute("open -a 'Mission Control'") end) -- Equivalente ao Win+Tab
hotkey.bind({"ctrl"}, 53, function() hs.execute("open -a 'Launchpad'") end) -- Abre o launchpad (ctrl+esc)
hotkey.bind({"ctrl","shift"}, 53, function() hs.execute("open -a 'Activity Monitor.app'") end) -- Abre o gerenciador de tarefas
hotkey.bind({"alt"}, "f", function() hs.execute("open -a 'Finder.app'") end) -- Abre o finder

-- Cria um único eventtap para todos os eventos de teclado em vez de múltiplos
local keyTap = eventtap.new({events.keyDown, events.keyUp}, function(event)
    -- Esta função será implementada posteriormente
    return false -- Por padrão, não consume o evento
end)

-- Função otimizada para simular pressionamento de tecla
local function fastKeyStroke(modifiers, key)
    eventtap.keyStroke(modifiers, key, keyboardEventDelay)
end

-- Função para criar atalhos de forma mais eficiente
local function createShortcuts()
    -- O que quero desabilitar
    local disableKeys = {
        {{"cmd"}, "q"},
        {{"cmd"}, "w"}
    }

    -- Remapeamento simples (tecla -> tecla com Cmd)
    local ctrlToCmd = {
        {"z", nil}, -- Desfazer
        {"x", nil}, -- Cortar
        {"v", nil}, -- Colar
        {"c", nil}, -- Copiar
        {"o", nil}, -- Abrir
        {"s", nil}, -- Salvar
        {"f", nil}, -- Buscar
        {"a", nil}, -- Selecionar Tudo
        {"p", nil}, -- Imprimir
        {"t", nil} --Nova aba
    }

    -- Casos especiais
    local specialCases = {
        {{"ctrl"}, "y", {"cmd", "shift"}, "z"}, -- Ctrl+Y -> Cmd+Shift+Z (Refazer)
        {{"ctrl", "shift"}, "t", {"cmd", "shift"}, "t"}, -- Restaurar uma aba
        {{"alt"}, "l", {"cmd", "ctrl"}, "q"} -- Bloquear tela
    }

    -- Navegação (códigos de tecla -> atalhos Cmd)
    local navigationKeys = {
        {115, {"cmd"}, 123},                            -- Home  -> Cmd + Left
        {{"shift"}, 115, {"cmd", "shift"}, 123},        -- Shift+Home -> Cmd + Shift + Left
        {119, {"cmd"}, 124},                            -- End   -> Cmd + Right
        {{"shift"}, 119, {"cmd", "shift"}, 124},        -- Shift+End -> Cmd + Shift + Right
        {{"ctrl"}, 115, {"cmd"}, 126},                  -- Ctrl+Home -> Cmd + Up
        {{"ctrl"}, 119, {"cmd"}, 125},                  -- Ctrl+End -> Cmd + Down
        {{"ctrl", "shift"}, 115, {"cmd", "shift"}, 126},-- Ctrl+Shift+Home -> Cmd + Shift + Up
        {{"ctrl", "shift"}, 119, {"cmd", "shift"}, 125},-- Ctrl+Shift+End -> Cmd + Shift + Down
        {{"ctrl", "shift"}, 123, {"alt", "shift"}, 123},-- Ctrl+Shift+Left -> Alt + Shift + Left
        {{"ctrl", "shift"}, 124, {"alt", "shift"}, 124} -- Ctrl+Shift+Right -> Alt + Shift + Right
    }

    -- Aplicar todas as configurações
    -- 1. Desabilitar teclas
    for _, key in ipairs(disableKeys) do hotkey.bind(key[1], key[2], nil, function() return true end) end

    -- 2. Remapear Ctrl para Cmd com delay reduzido
    for _, key in ipairs(ctrlToCmd) do hotkey.bind({"ctrl"}, key[1], nil, function() fastKeyStroke({"cmd"}, key[1]) end) end

    -- 3. Tratar casos especiais
    for _, map in ipairs(specialCases) do hotkey.bind(map[1], map[2], nil, function() fastKeyStroke(map[3], map[4]) end) end

    -- 4. Configurar teclas de navegação
    for _, nav in ipairs(navigationKeys) do
        if type(nav[1]) == "table" then
            -- Com modificadores (shift)
            hotkey.bind(nav[1], nav[2], nil, function() fastKeyStroke(nav[3], nav[4]) end)
        else
            -- Sem modificadores
            hotkey.bind({}, nav[1], nil, function() fastKeyStroke(nav[2], nav[3]) end)
        end
    end
end

-- Inicializar o módulo de performance
local function setupPerformanceSettings()
    -- Definir delay mínimo
    eventtap.keyRepeatInterval(0.03) -- Reduz o intervalo de repetição
    eventtap.keyRepeatDelay(0.15)    -- Reduz o delay inicial

    -- Ativar o tap para monitorar eventos
    keyTap:start()
end

function applicationWatcher(appName, eventType, app)
    -- Gerenciar atalhos no Finder
    if appName == "Finder" then
        if eventType == application.watcher.activated then
            -- Se já existir um watcher, evitamos criar outro
            if not keyboardWatcher then
                keyboardWatcher = eventtap.new({events.keyDown}, function(event)
                    local keyCode = event:getKeyCode()

                    if keyCode == 120 then -- F2 (Renomear)
                        isRenaming = true
                        app:selectMenuItem({"Arquivo", "Renomear"})
                        return true
                    elseif keyCode == 36 then -- ENTER/RETURN
                        if not isRenaming then
                            eventtap.keyStroke({"cmd"}, "o")
                            return true
                        else
                            isRenaming = false
                            return false
                        end
                    elseif keyCode == 117 then -- FORWARD DELETE (Excluir)
                        if not isRenaming then
                            eventtap.keyStroke({"cmd"}, "delete")
                            return true
                        else
                            return false
                        end
                    end
                    return false
                end)
                keyboardWatcher:start()
            end
        elseif eventType == application.watcher.deactivated then
            -- Para o observador de eventos de teclado quando o Finder é desativado
            if keyboardWatcher then
                keyboardWatcher:stop()
                keyboardWatcher = nil
            end
            isRenaming = false
        end
    end

    -- Tecla de atalho para mover mensagens de e-mail
    if appName == "Mail" then
        if eventType == application.watcher.activated then
            appleMailHotkeys = {
                hotkey.bind({"ctrl"}, "m", function()
                    app:selectMenuItem({"Mensagem", "Mover para"})
                    eventtap.keyStroke({}, "m", 1)
                    eventtap.keyStroke({}, "m", 1)
                    eventtap.keyStroke({}, "m", 1)
                    eventtap.keyStroke({}, "right", 1)
                    eventtap.keyStroke({}, "down", 1)
                    eventtap.keyStroke({}, "down", 1)
                    eventtap.keyStroke({}, "down", 1)
                    eventtap.keyStroke({}, "down", 1)
                    eventtap.keyStroke({}, "down", 1)
                    eventtap.keyStroke({}, "down", 1)
                end),
                hotkey.bind({"ctrl"}, "space", function()
                    eventtap.keyStroke({"shift","cmd"}, "u")
                end)
            }
        elseif eventType == application.watcher.deactivated then
            if appleMailHotkeys and type(appleMailHotkeys) == "table" then
                for _, hotkey in ipairs(appleMailHotkeys) do
                    if hotkey and type(hotkey.delete) == "function" then
                        pcall(function() hotkey:delete() end)
                    end
                end
                appleMailHotkeys = {} -- Reseta a tabela para evitar acessos inválidos
            end
        end
    end

    -- Gerenciar atalho do Safari
    if appName == "Safari" then
        if eventType == application.watcher.activated then
             if next(safariHotkeys) == nil then
                safariHotkeys = {
                    hotkey.bind({"cmd", "shift"}, "p", function()
                        app:selectMenuItem({"Visualizar", "Tradução", "Traduzir para Português"})
                        alert.show("Tradução PT-BR em andamento…")
                    end),
                    hotkey.bind({"cmd", "shift"}, "t", function()
                        app:selectMenuItem({"Visualizar", "Tradução", "Ver Original"})
                        alert.show("Voltando ao idioma original…")
                    end),
                    hotkey.bind({"ctrl"}, "u", function()
                        eventtap.keyStroke({"alt", "cmd"}, "u")
                    end),
                    hotkey.bind({"ctrl","shift"}, "i", function()
                        eventtap.keyStroke({"alt", "cmd"}, "i")
                    end),
                    hotkey.bind({}, "f12", function()
                        eventtap.keyStroke({"alt", "cmd"}, "c")
                    end),
                    hotkey.bind({}, "f5", function()
                        eventtap.keyStroke({"cmd"}, "r")
                    end),
                    hotkey.bind({"ctrl"}, "r", function()
                        eventtap.keyStroke({"cmd"}, "r")
                    end),
                    hotkey.bind({"ctrl"}, "f5", function()
                        eventtap.keyStroke({"alt","cmd"}, "e")
                        eventtap.keyStroke({"cmd"}, "r")
                    end),
                    hotkey.bind({"ctrl","shift"}, "r", function()
                        eventtap.keyStroke({"alt","cmd"}, "e")
                        eventtap.keyStroke({"cmd"}, "r")
                    end)
                }
            end
        elseif eventType == application.watcher.deactivated then
            if safariHotkeys and type(safariHotkeys) == "table" then
                for _, hotkey in ipairs(safariHotkeys) do
                    if hotkey and type(hotkey.delete) == "function" then
                        pcall(function() hotkey:delete() end)
                    end
                end
                safariHotkeys = {} -- Reseta a tabela para evitar acessos inválidos
            end
        end
    end
end

-- Monitoramento de teclas
appWatcher = application.watcher.new(applicationWatcher)
appWatcher:start()

-- Iniciar configuração dos atalhos
createShortcuts()
setupPerformanceSettings()

-- Movimentação das janelas
for _, bind in ipairs(windowBindings) do hotkey.bind(bind[1], bind[2], nil, function() moveWindow(bind[3]) end) end

-- Mapeia Ctrl + Left para Option + Left
local ctrlLeftWatcher = eventtap.new({eventtap.event.types.keyDown}, function(e)
    if e:getKeyCode() == 123 and e:getFlags().ctrl then  -- 123 é a tecla Left Arrow
        return true, {eventtap.event.newKeyEvent({"alt"}, "left", true)}
    end
end)

-- Mapeia Ctrl + Right para Option + Right
local ctrlRightWatcher = eventtap.new({eventtap.event.types.keyDown}, function(e)
    if e:getKeyCode() == 124 and e:getFlags().ctrl then  -- 124 é a tecla Right Arrow
        return true, {eventtap.event.newKeyEvent({"alt"}, "right", true)}
    end
end)

ctrlLeftWatcher:start()
ctrlRightWatcher:start()
