--[[
--Copyright (c) 2025 vinici.us.com. All Rights Reserved.
--Licensed under the MIT license.
--]]

-- ide.lua: Configurações específicas para IDEs

local config = require("config")
local ide = {}

-- Processa eventos da IDE
function ide.handleEvents(appName, eventType, app, state)
	if eventType == hs.application.watcher.activated then
		print("-- Configurando atalhos de teclado do " .. appName)
		ide.setupHotkeys(app, state)
	elseif eventType == hs.application.watcher.deactivated then
		print("-- O " .. appName .. " foi desativado")
		ide.clearHotkeys(state)
	end
end

-- Configura atalhos específicos para IDEs
function ide.setupHotkeys(app, state)
	local fastKeyStroke = hs.eventtap.keyStroke
	state.idesHotkeys = {
		hs.hotkey.bind({}, config.KeyCode.HOME, nil, function()
			fastKeyStroke({}, "home", config.keyboardEventDelay)
		end),
		hs.hotkey.bind({ "shift" }, config.KeyCode.HOME, nil, function()
			fastKeyStroke({ "shift" }, "home", config.keyboardEventDelay)
		end),
		hs.hotkey.bind({ "cmd" }, config.KeyCode.HOME, nil, function()
			fastKeyStroke({ "cmd" }, "home", config.keyboardEventDelay)
		end),
		hs.hotkey.bind({ "cmd", "shift" }, config.KeyCode.HOME, nil, function()
			fastKeyStroke({ "cmd", "shift" }, "home", config.keyboardEventDelay)
		end),
		hs.hotkey.bind({}, config.KeyCode.END, nil, function()
			fastKeyStroke({}, "end", config.keyboardEventDelay)
		end),
		hs.hotkey.bind({ "shift" }, config.KeyCode.END, nil, function()
			fastKeyStroke({ "shift" }, "end", config.keyboardEventDelay)
		end),
		hs.hotkey.bind({ "cmd" }, config.KeyCode.END, nil, function()
			fastKeyStroke({ "cmd" }, "end", config.keyboardEventDelay)
		end),
		hs.hotkey.bind({ "cmd", "shift" }, config.KeyCode.END, nil, function()
			fastKeyStroke({ "cmd", "shift" }, "end", config.keyboardEventDelay)
		end),
	}
end

-- Limpa os atalhos criados aqui
function ide.clearHotkeys(state)
	if state.idesHotkeys then
		for _, hotkey in pairs(state.idesHotkeys) do
			if hotkey and type(hotkey.delete) == "function" then
				pcall(function() hotkey:delete() end)
			end
		end
		state.idesHotkeys = {}
	end
end

return ide
