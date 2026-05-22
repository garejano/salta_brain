-- commands.lua
-- Registro central de comandos _pde disponíveis no WezTerm.
-- Aberto via paleta de comandos (Leader+P por padrão).
--
-- Para adicionar um comando: inserir uma entrada em M.registry com
-- os campos id, label, description e run(window, pane).

local wezterm = require("wezterm")
local M = {}

-- ─── Helpers ────────────────────────────────────────────────────────────────

local function toast(window, msg, duration_ms)
	window:toast_notification("_pde", msg, nil, duration_ms or 3000)
end

-- ─── Registro de comandos ────────────────────────────────────────────────────

M.registry = {

	-- ── Claude Detector ──────────────────────────────────────────────────────

	{
		id          = "claude_list_panes",
		label       = "Claude · listar painéis com Claude ativo",
		description = "Exibe quantos painéis têm um processo claude em foreground",
		run = function(window, pane)
			local ok, detector = pcall(require, "claude_detector")
			if not ok then
				toast(window, "Erro ao carregar claude_detector: " .. tostring(detector))
				return
			end
			local panes = detector.find_claude_panes(window)
			if #panes == 0 then
				toast(window, "Nenhum painel com Claude ativo")
			else
				local lines = { "Claude ativo em " .. #panes .. " painel(s):" }
				for _, p in ipairs(panes) do
					table.insert(lines, "  tab=" .. p.tab_id .. "  pane=" .. p.pane_id)
				end
				toast(window, table.concat(lines, "\n"), 5000)
			end
		end,
	},

	{
		id          = "claude_enable_tab_indicator",
		label       = "Claude · ativar indicador visual nas abas",
		description = "Registra o evento format-tab-title para destacar abas com Claude",
		run = function(window, pane)
			local ok, detector = pcall(require, "claude_detector")
			if not ok then
				toast(window, "Erro ao carregar claude_detector: " .. tostring(detector))
				return
			end
			detector.setup()
			toast(window, "Indicador Claude ativado (◆ laranja nas abas com Claude)")
		end,
	},

}

-- ─── Utilitários ─────────────────────────────────────────────────────────────

-- Converte o registro para o formato aceito pelo InputSelector do WezTerm.
function M.as_choices()
	local choices = {}
	for _, cmd in ipairs(M.registry) do
		table.insert(choices, {
			id    = cmd.id,
			label = cmd.label,
		})
	end
	return choices
end

-- Executa um comando pelo id. Retorna true se encontrado, false se não.
function M.run(id, window, pane)
	for _, cmd in ipairs(M.registry) do
		if cmd.id == id then
			cmd.run(window, pane)
			return true
		end
	end
	return false
end

return M
