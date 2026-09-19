-- Pull in the wezterm API
local wezterm = require("wezterm")
-- Claude Code の実行状態を監視するヘルパー
local agent = require("agent")

-- This will hold the configuration.
local config = wezterm.config_builder()

function merge_config(config, new_config)
	for k, v in pairs(new_config) do
		config[k] = v
	end
end

-- This is where you actually apply your config choices
config.use_ime = true
config.macos_forward_to_ime_modifier_mask = "SHIFT|CTRL"
config.status_update_interval = 200

local scheme = wezterm.color.get_builtin_schemes()["JetBrains Darcula"]
scheme.ansi[3] = "#6ac06a" -- green (Lua は 1 始まり)
scheme.ansi[5] = "#7eaef1" -- blue
scheme.brights[5] = "#8cb4ff" -- bright blue
scheme.foreground = "#FFFFFF"
scheme.background = "#2B2B2B"

config.color_schemes = { ["Darcula Custom"] = scheme }
config.color_scheme = "Darcula Custom"
config.font = wezterm.font("HackGen35")
config.font_size = 13.0
local TAB_BAR_BG = "#47266e"

config.window_frame = {
	font = wezterm.font("JetBrains Mono", { italic = true }),
  font_size = 13.0,
	active_titlebar_bg = TAB_BAR_BG,
}
config.tab_max_width = 16
config.initial_cols = 210
config.initial_rows = 60

config.inactive_pane_hsb = {
	saturation = 0.7,
	brightness = 0.6,
}

config.tab_bar_at_bottom = true
config.enable_scroll_bar = true
config.scrollback_lines = 1000000
config.window_close_confirmation = "NeverPrompt"
config.audible_bell = "Disabled"

local act = wezterm.action

-- overlay pane (leader+o などで spawn したペイン) の pane_id -> タブバーの印。
-- 値がそのままタブタイトルに連結される
local overlay_panes = {}

local OVERLAY_SHELL = "/opt/homebrew/bin/brush"

local function toggle_overlay_pane(cmd, marker)
	local args = { OVERLAY_SHELL, "--login" }
	if cmd then
		args = { OVERLAY_SHELL, "--login", "-c", cmd .. "; exec " .. OVERLAY_SHELL .. " --login" }
	end

	return wezterm.action_callback(function(window, pane)
		-- overlay ペインに居るなら閉じる (yazi 実行中でも exit 不要で落とす)
		if overlay_panes[pane:pane_id()] then
			overlay_panes[pane:pane_id()] = nil
			window:active_tab():set_zoomed(false)
			window:perform_action(act.CloseCurrentPane({ confirm = false }), pane)
			return
		end

		local new_pane = pane:split({
			direction = "Bottom",
			args = args,
		})
		overlay_panes[new_pane:pane_id()] = marker or "💩 "
		window:perform_action(act.TogglePaneZoomState, new_pane)
	end)
end

config.leader = { key = "q", mods = "CTRL" }
config.keys = {
	{
		key = "v",
		mods = "LEADER|CTRL",
		action = wezterm.action.SplitVertical({ domain = "CurrentPaneDomain" }),
	},
	{
		key = "s",
		mods = "LEADER|CTRL",
		action = wezterm.action.SplitHorizontal({ domain = "CurrentPaneDomain" }),
	},
	{ key = "h", mods = "LEADER|CTRL", action = wezterm.action.ActivatePaneDirection("Left") },
	{ key = "l", mods = "LEADER|CTRL", action = wezterm.action.ActivatePaneDirection("Right") },
	{ key = "k", mods = "LEADER|CTRL", action = wezterm.action.ActivatePaneDirection("Up") },
	{ key = "j", mods = "LEADER|CTRL", action = wezterm.action.ActivatePaneDirection("Down") },
	{ key = "r", mods = "LEADER|CTRL", action = act.ActivateKeyTable({ name = "resize_pane", one_shot = false }) },
	{ key = "z", mods = "LEADER|CTRL", action = wezterm.action.TogglePaneZoomState },
	{ key = "f", mods = "LEADER|CTRL", action = wezterm.action.QuickSelect },
	{ key = "c", mods = "ALT", action = wezterm.action.CopyTo("Clipboard") },
	{ key = "v", mods = "ALT", action = wezterm.action.PasteFrom("Clipboard") },
	{
		key = "c",
		mods = "LEADER|CTRL",
		action = act.PromptInputLine({
			description = wezterm.format({
				{ Attribute = { Intensity = "Bold" } },
				{ Foreground = { AnsiColor = "Fuchsia" } },
				{ Text = "Enter name for new workspace" },
			}),
			action = wezterm.action_callback(function(window, pane, line)
				if line then
					window:perform_action(
						act.SwitchToWorkspace({
							name = line,
						}),
						pane
					)
				end
			end),
		}),
	},
	{
		key = "w",
		mods = "LEADER|CTRL",
		action = act.ShowLauncherArgs({
			flags = "FUZZY|WORKSPACES",
		}),
	},
	{ key = "n", mods = "LEADER|CTRL", action = act.SwitchWorkspaceRelative(1) },
	{ key = "p", mods = "LEADER|CTRL", action = act.SwitchWorkspaceRelative(-1) },
	{ key = "[", mods = "LEADER|CTRL", action = wezterm.action.ActivateCopyMode },
	{
		key = "t",
		mods = "ALT",
		action = act.SpawnTab("CurrentPaneDomain"),
	},
	{
		key = "o",
		mods = "LEADER|CTRL",
		action = toggle_overlay_pane(),
	},
	{
		key = "y",
		mods = "LEADER|CTRL",
		action = toggle_overlay_pane("y", "📁 "),
	},
	{
		key = "e",
		mods = "LEADER|CTRL",
		action = toggle_overlay_pane("nvim", "📝 "),
	},
  {
		key = "t",
		mods = "LEADER|CTRL",
		action = toggle_overlay_pane("tig", "💣 "),
	},
	-- Claude Code のセッション一覧を開き、選んだペインへジャンプする
	{
		key = "a",
		mods = "LEADER|CTRL",
		action = agent.dashboard_action(),
	},
}

config.key_tables = {
	resize_pane = {
		{ key = "h", action = act.AdjustPaneSize({ "Left", 5 }) },
		{ key = "l", action = act.AdjustPaneSize({ "Right", 5 }) },
		{ key = "k", action = act.AdjustPaneSize({ "Up", 5 }) },
		{ key = "j", action = act.AdjustPaneSize({ "Down", 5 }) },
		{ key = "Enter", action = "PopKeyTable" },
	},
}

-- パスの各ディレクトリ(最後を除く)を頭文字だけにして短縮する。例: ~/github.com/foo/bar -> ~/g/foo/bar
local function shorten_path(path)
	local parts = {}
	local is_home = path:sub(1, 1) == "~"
	local start_idx = is_home and 2 or 1

	for part in path:sub(start_idx):gmatch("[^/]+") do
		table.insert(parts, part)
	end

	for i = 1, #parts - 1 do
		parts[i] = parts[i]:sub(1, 1)
	end

	local result = is_home and "~/" or "/"
	result = result .. table.concat(parts, "/")

	if path:sub(-1) == "/" and result:sub(-1) ~= "/" then
		result = result .. "/"
	end

	return result
end

-- タブのアクティブペインの cwd を短縮パスにして返す。取得できなければ nil
local function tab_cwd(tab)
	local ok, mux_pane = pcall(wezterm.mux.get_pane, tab.active_pane.pane_id)
	if not ok or not mux_pane then
		return nil
	end

	local cwd_uri = mux_pane:get_current_working_dir()
	if not cwd_uri then
		return nil
	end

	local path = cwd_uri.file_path
	local home = os.getenv("HOME")
	if home and path:sub(1, #home) == home then
		path = "~" .. path:sub(#home + 1)
	end

	return shorten_path(path)
end

local TAB_ACTIVE_BG = "#8b008b"
local TAB_INACTIVE_BG = "#696969"
local TAB_FG = "#FFFFFF"

-- ── モード表示 (タブの左) ─────────────────────────────
-- key table 名 -> ラベルと配色
local MODE_STYLES = {
	copy_mode = { label = "COPY", bg = "#d79921" },
	search_mode = { label = "SEARCH", bg = "#458588" },
	resize_pane = { label = "RESIZE", bg = "#689d6a" },
}
local LEADER_STYLE = { label = "LEADER", bg = "#b16286" }
local NORMAL_STYLE = { label = "NORMAL", bg = TAB_INACTIVE_BG }

-- powerline の > (タブバー背景へ繋ぐ)
local SOLID_RIGHT_ARROW = utf8.char(0xe0b0)

-- 現在のモードをタブの左に描く
local function update_mode_status(window)
	local mode = MODE_STYLES[window:active_key_table() or ""]
	if not mode and window:leader_is_active() then
		mode = LEADER_STYLE
	end
	mode = mode or NORMAL_STYLE

	window:set_left_status(wezterm.format({
		{ Background = { Color = mode.bg } },
		{ Foreground = { Color = TAB_FG } },
		{ Attribute = { Intensity = "Bold" } },
		{ Text = " " .. mode.label .. " " },
		"ResetAttributes",
		{ Foreground = { Color = mode.bg } },
		{ Text = SOLID_RIGHT_ARROW },
	}))
end

wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
	local background = tab.is_active and TAB_ACTIVE_BG or TAB_INACTIVE_BG
	local foreground = TAB_FG

	local marker = ""
	for _, p in ipairs(tab.panes) do
		if overlay_panes[p.pane_id] then
			marker = marker .. overlay_panes[p.pane_id]
			break
		end
	end

	local label = tab_cwd(tab) or tab.active_pane.title
	local title = "  " .. marker .. wezterm.truncate_right(label, max_width - 1) .. "   "

	return {
		{ Background = { Color = background } },
		{ Foreground = { Color = foreground } },
		{ Text = title },
	}
end)

wezterm.on("augment-command-palette", function()
	return agent.palette_entries()
end)

wezterm.on("update-status", function(window, pane)
	update_mode_status(window)

	-- Each element holds the text for a cell in a "powerline" style << fade
	local cells = {}

	-- Claude Code の状態をスキャンし、状態遷移を通知する
	local agents = agent.scan()
	for _, ev in ipairs(agent.take_events()) do
		local body = ev.kind == "waiting" and " が入力待ちです" or " が完了しました"
		window:toast_notification("Claude Code", ev.agent.project .. body, nil, 4000)
	end

	-- workspace ごとにエージェントをグループ化
	local agents_by_workspace = {}
	for _, a in ipairs(agents) do
		agents_by_workspace[a.workspace] = agents_by_workspace[a.workspace] or {}
		table.insert(agents_by_workspace[a.workspace], a)
	end

	-- Get list of workspaces from the mux (no subprocess needed)
	local active_workspace = window:active_workspace()

	local unique_workspaces = { [active_workspace] = true }
	for _, mux_win in ipairs(wezterm.mux.all_windows()) do
		unique_workspaces[mux_win:get_workspace()] = true
	end

	local workspaces = {}
	for ws in pairs(unique_workspaces) do
		table.insert(workspaces, ws)
	end
	table.sort(workspaces)

	-- workspace ごとに、そこに居るエージェントのアイコン一覧を付けて 1 セルとして追加する。
	-- active かどうかは push() 側で配色を変えるために保持しておく
	for _, ws in ipairs(workspaces) do
		local label = "[" .. ws .. "]"
		for _, a in ipairs(agents_by_workspace[ws] or {}) do
			label = label .. " " .. agent.status_icon(a.status) .. a.project
		end
		table.insert(cells, { text = label, active = ws == active_workspace })
	end

	-- The filled in variant of the < symbol
	local SOLID_LEFT_ARROW = utf8.char(0xe0b2)
	local CELL_GAP = " "

	-- The elements to be formatted
	local elements = {}

	-- 全セルを tab と同じ配色にする(active なら TAB_ACTIVE_BG、非 active なら TAB_INACTIVE_BG)
	local function cell_colors(cell)
		return cell.active and TAB_ACTIVE_BG or TAB_INACTIVE_BG, TAB_FG
	end

	-- Translate a cell into elements
	local function push(cell, is_first)
		local bg, text_fg = cell_colors(cell)

		-- タブバー背景に戻してから、そのセルの色で < を描く
		table.insert(elements, "ResetAttributes")
		table.insert(elements, { Background = { Color = TAB_BAR_BG } })
		if not is_first then
			table.insert(elements, { Text = CELL_GAP })
		end
		table.insert(elements, { Foreground = { Color = bg } })
		table.insert(elements, { Text = SOLID_LEFT_ARROW })

		table.insert(elements, { Foreground = { Color = text_fg } })
		table.insert(elements, { Background = { Color = bg } })
		table.insert(elements, { Text = " " .. cell.text .. " " })

		-- 右端もタブバー色で < に削り、セルを < 形で閉じる
		table.insert(elements, { Foreground = { Color = TAB_BAR_BG } })
		table.insert(elements, { Text = SOLID_LEFT_ARROW })
	end

	for i, cell in ipairs(cells) do
		push(cell, i == 1)
	end

	window:set_right_status(wezterm.format(elements))
end)

local custom = require("/custom")
merge_config(config, custom)

-- and finally, return the configuration to wezterm
return config
