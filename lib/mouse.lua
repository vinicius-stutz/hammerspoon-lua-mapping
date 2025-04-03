-- mouse.lua: Funções relacionadas a eventos do mouse

local mouse = {}

-- Carrega as bibliotecas necessárias do Hammerspoon
local eventtap = hs.eventtap
local eventTypes = eventtap.event.types

-- Variável para armazenar o eventtap
mouse.modifierSwapTap = nil

-- Função para iniciar o swapper de CMD/CTRL
function mouse.startModifierSwap()
    -- Se já estiver ativo, não cria outro
    if mouse.modifierSwapTap then
        return
    end
    
    -- Cria um eventtap que vai monitorar os cliques do mouse
    mouse.modifierSwapTap = eventtap.new({eventTypes.leftMouseDown, eventTypes.leftMouseUp}, function(event)
        -- Captura as flags atuais do evento
        local flags = event:getFlags()
        
        -- Caso 1: CTRL está pressionado, converte para CMD
        if flags.ctrl and not flags.cmd then
            flags.ctrl = nil
            flags.cmd = true
            event:setFlags(flags)
        -- Caso 2: CMD está pressionado, converte para CTRL
        elseif flags.cmd and not flags.ctrl then
            flags.cmd = nil
            flags.ctrl = true
            event:setFlags(flags)
        end
        
        -- Permite que o evento continue
        return false
    end)
    
    -- Ativa o eventtap
    mouse.modifierSwapTap:start()
    
    return true
end

-- Função para parar o swapper
function mouse.stopModifierSwap()
    if mouse.modifierSwapTap then
        mouse.modifierSwapTap:stop()
        mouse.modifierSwapTap = nil
        return true
    end
    return false
end

-- Função para alternar o estado do swapper
function mouse.toggleModifierSwap()
    if mouse.modifierSwapTap then
        return mouse.stopModifierSwap()
    else
        return mouse.startModifierSwap()
    end
end

-- Inicia o swapper automaticamente quando o módulo é carregado
mouse.startModifierSwap()

-- Retorna o módulo
return mouse