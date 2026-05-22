local wezterm = require 'wezterm'

local lib = wezterm.plugin.require("https://github.com/chrisgve/lib.wezterm")

local act = wezterm.action
local mux = wezterm.mux

function teste()
end

-- local window_frame = require 'window_frame'

local npr = "npm run dev"
local paths = {
	projects = "c:/projects/",
	note_config = "c:/Users/gustavo.arejano",
	config = "c:/Users/arejano",
}

local default_applications = {
	editor = "hx"
}

local pane_tracker = {
	helix_panes = {}
}

local custom_colors = {
	leader = "#282864",
	normal = "#282864",
	error = "#282864",
}

-- local custom_colors = {
-- 	leader = "#CA9EE6",
-- 	normal = "#faa356",
-- 	error = "#fa7970",
-- }

local date_table = os.date("*t")
local date_string = date_table.day .. "." .. date_table.month .. "." .. date_table.year
local time = date_table.hour .. ":" .. date_table.min
local hour = tonumber(date_table.hour)


local config = {}

if wezterm.config_builder then
	config = wezterm.config_builder()
end


local themes = {
	nil,
	"Gruvbox light, medium (base16)",
	"Catppuccin Mocha",
	"Catppuccin Frappe",
	"Catppuccin Macchiato",
	"Catppuccin Latte",
	"Batman",
}
config.color_scheme = themes[1];

config.default_cwd = "c:/projects"
config.font_size = 10.

-- config.window_frame = window_frame

config.enable_tab_bar = true
-- config.hide_tab_bar_if_only_one_tab = true
config.window_decorations = "RESIZE"
config.use_fancy_tab_bar = false
config.status_update_interval = 1000
config.tab_bar_at_bottom = false

config.window_padding = {
	left = 0,
	right = 0,
	top = 0,
	bottom = 0,
}

config.colors = {
	tab_bar = {
		background = "#282864",
		active_tab = {
			fg_color = '#FFF',
			bg_color = '#000'
		},
		inactive_tab = {
			fg_color = '#FFFFFF',
			bg_color = '#282864'
		},
		new_tab = {
			fg_color = '#FFFFFF',
			bg_color = '#282864'
		}
	}
}

-- Cria um layout estilo "IDE"
wezterm.on("SpawnIDE", function(window, pane)
	-- Primeiro, pega a window atual e cria o split da esquerda
	local left = window:active_pane():split {
		direction = "Left",
		size = 60.0 / window:get_dimensions().pixel_width, -- largura fixa em "cols"
		args = { "spf" },                                -- Superfile
	}

	-- Agora abre o Helix no pane direito
	local right = left:split {
		direction = "Right",
		size = 1.0, -- ocupa todo o espaço restante
		args = { "hx" },
	}

	-- Opcional: salvar o pane_id do Helix para o Superfile poder enviar arquivos
	local helix_pane_id = tostring(right:pane_id())
	local tmpfile = os.getenv("HOME") .. "/.helix_pane_id"
	local f = io.open(tmpfile, "w")
	if f then
		f:write(helix_pane_id)
		f:close()
	end
end)


-- timeout_milliseconds defaults to 1000 and can be omitted
config.leader = { key = 'a', mods = 'CTRL', timeout_milliseconds = 1000 }


config.keys = {
	{
		key = "i",
		mods = "CTRL|SHIFT",
		action = wezterm.action.EmitEvent("SpawnIDE"),
	},
	{
		key = "H",
		mods = 'CTRL|SHIFT',
		action = wezterm.action_callback(function(window, pane)
			local tab = window:active_tab()
			pane:send_text("spf\r")
			wezterm.sleep_ms(100)
			pane:split { direction = "Right", size = 0.70, args = { "hx" } }
			wezterm.sleep_ms(100)
			window:perform_action(wezterm.action.ActivatePaneDirection "Left", pane)
			pane:send_text("spf\r")
			pane:split { direction = "Bottom", size = 0.2 }
		end)
	},
	-- { key = "F1", mods = 'NONE',   action = 'ActivateCopyMode' },
	-- { key = "F2", mods = 'NONE',   action = act.ActivateCommandPalette },
	-- { key = "F3", mods = 'NONE',   action = act.ShowLauncherArgs({ flags = "FUZZY|TABS" }) },
	{ key = 'h',  mods = 'LEADER', action = act.ActivateTabRelative(-1) },
	{ key = 'l',  mods = 'LEADER', action = act.ActivateTabRelative(1) },
	{ key = '[',  mods = 'CTRL',   action = act.ActivateTabRelative(-1) },
	{ key = ']',  mods = 'CTRL',   action = act.ActivateTabRelative(1) },
	{ key = 't',  mods = 'LEADER', action = act.ShowTabNavigator },

	-- Workspaces
	{ key = "w",  mods = "LEADER", action = act.ShowLauncherArgs { flags = "FUZZY|WORKSPACES" } },
	-- End Workspaces

	{
		key = '|',
		mods = 'LEADER|SHIFT',
		action = wezterm.action.SplitHorizontal { domain = 'CurrentPaneDomain' },
	},
	{
		key = '%',
		mods = 'LEADER|SHIFT',
		action = wezterm.action.SplitVertical { domain = 'CurrentPaneDomain' },
	},
	-- Send "CTRL-A" to the terminal when pressing CTRL-A, CTRL-A
	{ key = 'a', mods = 'LEADER|CTRL', action = act.SendKey { key = 'a', mods = 'CTRL' }, },
	-- MovePanes
	{ key = 'h', mods = 'CTRL',        action = act.ActivatePaneDirection 'Left', },
	{ key = 'l', mods = 'CTRL',        action = act.ActivatePaneDirection 'Right', },
	{ key = 'k', mods = 'CTRL',        action = act.ActivatePaneDirection 'Up', },
	{ key = 'j', mods = 'CTRL',        action = act.ActivatePaneDirection 'Down', },
	{ key = 'l', mods = 'CTRL|ALT',    action = act.MoveTabRelative(1) },
	{ key = 'h', mods = 'CTRL|ALT',    action = act.AdjustPaneSize { 'Left', 10 } },
	{ key = 'j', mods = 'CTRL|ALT',    action = act.AdjustPaneSize { 'Down', 10 } },
	{ key = 'k', mods = 'CTRL|ALT',    action = act.AdjustPaneSize { 'Up', 10 } },
	{ key = 'l', mods = 'CTRL|ALT',    action = act.AdjustPaneSize { 'Right', 10 } },
	{ key = 'f', mods = 'ALT',         action = "ToggleFullScreen", },

	{ key = '1', mods = 'ALT',         action = act.ActivateTab(1 - 1) },
	{ key = '2', mods = 'ALT',         action = act.ActivateTab(2 - 1) },
	{ key = '3', mods = 'ALT',         action = act.ActivateTab(3 - 1) },
	{ key = '4', mods = 'ALT',         action = act.ActivateTab(4 - 1) },
	{ key = '5', mods = 'ALT',         action = act.ActivateTab(5 - 1) },
	{ key = '6', mods = 'ALT',         action = act.ActivateTab(6 - 1) },
	{ key = '7', mods = 'ALT',         action = act.ActivateTab(7 - 1) },
	{ key = '8', mods = 'ALT',         action = act.ActivateTab(8 - 1) },
	{ key = '9', mods = 'ALT',         action = act.ActivateTab(9 - 1) },

	{
		key = 'R',
		mods = 'CTRL|SHIFT',
		action = act.SplitVertical { domain = 'CurrentPaneDomain',
			label = 'Front-estrutura pedagogica && npm run',
			cwd = paths.projects .. "estrutura-pedagogica",
			args = { 'npm', 'run', 'dev' }
			-- args = 'dir'
		},
	},
	{
		key = "q",
		mods = "CTRL|SHIFT",
		action = act.CloseCurrentPane { confirm = true },
	},

	{
		key = "d",
		mods = "CTRL|SHIFT",
		action = wezterm.action_callback(function(window, pane)
			-- Foca o split abaixo
			window:perform_action(wezterm.action.ActivatePaneDirection "Left", pane)
			window:perform_action(wezterm.action.ActivatePaneDirection "Down", pane)

			-- Espera um pouquinho pra ter certeza que o foco mudou
			wezterm.sleep_ms(100)

			-- Pega o novo pane ativo e envia o comando
			local new_pane = window:active_pane()

			new_pane:send_text("run.bat\r")
			-- new_pane:send_text("love .\r")


			-- Volta pro split anterior (pra cima)
			window:perform_action(wezterm.action.ActivatePaneDirection "Right", new_pane)
		end),
	},


	{
		key = "b",
		mods = "CTRL|SHIFT",
		action = wezterm.action_callback(function(window, pane)
			window:perform_action(wezterm.action.ActivatePaneDirection "Left", pane)
			window:perform_action(wezterm.action.ActivatePaneDirection "Down", pane)

			-- Espera um pouquinho pra ter certeza que o foco mudou
			wezterm.sleep_ms(100)

			-- Pega o novo pane ativo e envia o comando
			local new_pane = window:active_pane()

			new_pane:send_text("cls\r")
			new_pane:send_text("zig build run\r")

			-- Volta pro split anterior (pra cima)
			window:perform_action(wezterm.action.ActivatePaneDirection "Right", new_pane)
		end),
	},

	{
		key = "y",
		mods = "CTRL|SHIFT",
		action = wezterm.action_callback(function(window, pane)
			send_to_helix(window, "c:/projects/teste.txt")
		end),
	},

	{
		key = "k",
		mods = "CTRL|SHIFT",
		action = wezterm.action_callback(function(window, pane)
			-- pane:send_text("spf\r")

			local tab = window:active_tab()

			-- helix panel
			local new_pane = pane:split { direction = "Right", size = 0.80 }
			wezterm.sleep_ms(100)

			-- to left

			-- window:perform_action(wezterm.action.ActivatePaneDirection "Left", new_pane)
			-- local debug_panel = pane:split { direction = "Down", size = 0.80 }

			-- window:perform_action(wezterm.action.ActivatePaneDirection "Right", pane)

			-- window:perform_action(wezterm.action.ActivatePaneDirection "Left", pane)
			-- window:perform_action(wezterm.action.ActivatePaneDirection "Down", pane)

			-- wezterm.sleep_ms(100)

			-- local new_pane = window:active_pane()

			-- new_pane:send_text("run.bat\r")
			-- window:perform_action(wezterm.action.ActivatePaneDirection "Right", new_pane)
		end),
	},

}

wezterm.on('gui-startup', function()
	local tab_code, _, window = mux.spawn_window {
		cwd = 'C:/Users/gustavo.arejano/AppData/Roaming/DBeaverData/workspace6/General/Scripts',
	}
	window:gui_window():maximize()

	tab_code:set_title "code"

	local tab_files, _, _ = window:spawn_tab { cwd = 'c:/projects', }
	tab_files:set_title "code"

	-- Files
	local tab_files, _, _ = window:spawn_tab { cwd = 'c:/Users/arejano', }
	tab_files:set_title "config"

	-- Documentacao-Pedagogica
	local tab_doc, _, _ = window:spawn_tab {
		cwd = paths.projects .. 'documentacao-pedagogica/frontend',
		-- args = {'hx'}
	}
	tab_doc:set_title "doc-ped"


	-- Portal
	local tab_portal, _, _ = window:spawn_tab {
		cwd = paths.projects .. 'portal-atlas',
	}
	tab_portal:set_title "portal"


	--Tab, panel, window
	local play_tab, _, _ = window:spawn_tab {
		cwd = paths.projects .. 'estrutura-pedagogica/frontend',
	}
	play_tab:set_title "estr-ped"

	--Tab, panel, window
	local play, _, _ = window:spawn_tab {
		cwd = paths.projects .. "pde_salta",
	}
	play:set_title "claude"
end)


wezterm.on("update-status", function(window, pane)
	-- Trocar a cor baseada na hora do dia para usar light theme caso apos as 06am
	-- if hour > 6 then stat_color = "#FFF" end

	-- Current working directory
	local basename = function(s)
		-- 	-- Nothing a little regex can't fix
		return string.gsub(s, "(.*[/\\])(.*)", "%2")
	end

	-- Time
	-- local time = wezterm.strftime("%H:%M")

	update_left_status(window, pane)
	update_right_status(window, pane)
end)

function update_left_status(window, _)
	-- local tab = window:active_tab()
	local mode = "N"
	local mode_color = custom_colors.normal

	-- It's a little silly to have workspace name all the time
	-- Utilize this to display LDR or current key table name
	if window:active_key_table() then
		mode_color = custom_colors.normal
	end
	if window:leader_is_active() then
		mode = "L"
		mode_color = custom_colors.leader
	end


	window:set_left_status(wezterm.format({
		{ Background = { Color = mode_color } },
		{ Foreground = { Color = "#FFF" } },
		{ Text = " " .. mode .. " " },
	}))
end

function update_right_status(window, pane)
	local cwd_text = "none"
	local process_text = "."
	local cwd = window:active_pane():get_current_working_dir()
	if cwd ~= nil then
		local text = tostring(cwd)
		if type(text) == "string" then
			cwd_text = text:gsub("file:///", "")
		end
	end

	local process_name = pane:get_foreground_process_name()

	if process_name ~= nil then
		local text = tostring(process_name)
		if type(process_name) == "string" then
			process_text = text:gsub(".*\\", "")
		end
	end

	local to_render = {
		{ Background = { Color = custom_colors.normal } },
		{ Foreground = { Color = "#FFF" } },
		{ Text = " " .. wezterm.nerdfonts.md_code_brackets .. " " .. process_text .. " " },
		{ Background = { Color = custom_colors.error } },
		{ Text = " " .. wezterm.nerdfonts.cod_folder_opened .. " " .. cwd_text },
		{ Background = { Color = custom_colors.normal } },
		{ Text = " " .. wezterm.nerdfonts.cod_calendar .. "  " .. date_string .. " " },
	}
	window:set_right_status(wezterm.format(to_render))
end

config.launch_menu = {
	{
		label = "Conectar ao servidor",
		args = { "hx" }
	}
}


return config
