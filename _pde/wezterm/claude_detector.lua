-- claude_detector.lua
-- Detecta painéis com processo Claude ativo e destaca visualmente na tab bar.
--
-- Uso: require este módulo no wezterm.lua principal e registre os eventos
-- conforme descrito abaixo.
--
-- Dependência: WezTerm >= 20230712 (suporte a get_foreground_process_name)

local wezterm = require("wezterm")

local M = {}

-- Retorna true se o nome do processo indica uma sessão Claude CLI.
local function is_claude_process(name)
	if not name then
		return false
	end
	-- Cobre "claude", "claude.exe", caminhos absolutos tipo "/usr/bin/claude"
	return name:match("[/\\]?claude(.exe)?$") ~= nil
end

-- Verifica se algum painel da janela tem Claude rodando.
-- Retorna a lista de IDs dos painéis com Claude ativo.
function M.find_claude_panes(window)
	local panes_with_claude = {}
	for _, tab in ipairs(window:tabs()) do
		for _, pane_info in ipairs(tab:panes_with_info()) do
			local pane = pane_info.pane
			local proc = pane:get_foreground_process_name()
			if is_claude_process(proc) then
				table.insert(panes_with_claude, {
					tab_id = tab:tab_id(),
					pane_id = pane:pane_id(),
					process = proc,
				})
			end
		end
	end
	return panes_with_claude
end

-- Retorna true se a janela tiver ao menos um painel com Claude ativo.
function M.window_has_claude(window)
	return #M.find_claude_panes(window) > 0
end

-- Formata o título de uma aba incluindo indicador visual quando Claude está ativo.
-- Destinado ao evento format-tab-title do WezTerm.
--
-- Registro no wezterm.lua:
--   local claude_detector = require("_pde/wezterm/claude_detector")
--   wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
--     return claude_detector.format_tab_title(tab, hover)
--   end)
function M.format_tab_title(tab, hover)
	local has_claude = false

	for _, pane_info in ipairs(tab:panes_with_info()) do
		local proc = pane_info.pane:get_foreground_process_name()
		if is_claude_process(proc) then
			has_claude = true
			break
		end
	end

	local title = tab:get_title()
	if title == nil or title == "" then
		title = "Tab " .. (tab:tab_id() + 1)
	end

	if has_claude then
		return {
			{ Foreground = { Color = "#f5a623" } }, -- laranja para abas com Claude
			{ Text = "◆ " .. title },
			{ Foreground = { Color = "Default" } },
		}
	end

	return title
end

-- Registra os eventos necessários diretamente (alternativa ao registro manual).
-- Chame M.setup() no wezterm.lua principal se preferir delegar o registro aqui.
function M.setup()
	wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
		return M.format_tab_title(tab, hover)
	end)
end

return M
