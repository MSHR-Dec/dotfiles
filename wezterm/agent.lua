local wezterm = require("wezterm")
local act = wezterm.action

local M = {}

local STATUS_ICON = { running = "🤖", waiting = "💬", idle = "💤" }
local STATUS_NERD_ICON =
	{ running = "md_robot", waiting = "md_robot_confused_outline", idle = "md_robot_off_outline" }

-- ~/.claude/sessions/<pid>.json の status を pane 表示用ステータスへ変換
local SESSION_STATUS = { busy = "running", waiting = "waiting", idle = "idle", shell = "idle" }
local SESSIONS_DIR = os.getenv("HOME") .. "/.claude/sessions"

-- ps の実行コストを抑えるための TTL キャッシュ
local CACHE_TTL = 3
local cache = { agents = {}, by_pane = {}, timestamp = 0 }
local prev_status = {} -- pane_id -> 前回スキャン時の状態
local events = {} -- 通知すべき状態遷移のキュー { agent = a, kind = "completed"|"waiting" }

-- ppid チェーンを遡って claude プロセスを探す
local function find_claude_ancestor(pid, procs, claude_pids)
	local visited = {}
	local current = pid
	while current and current > 1 and not visited[current] do
		visited[current] = true
		if claude_pids[current] then
			return current
		end
		local info = procs[current]
		if not info then
			break
		end
		current = info.ppid
	end
	return nil
end

-- ~/.claude/sessions/*.json を読み、pid -> セッション情報 のテーブルを返す
-- Claude Code 本体がプロセスごとに書き出すファイルで、name(自動生成された短い名前)や
-- status(busy/waiting/idle/shell) が入っている。caffeinate 子プロセスの有無より正確
local function read_sessions()
	local sessions = {}
	local ok, entries = pcall(wezterm.read_dir, SESSIONS_DIR)
	if not ok or not entries then
		return sessions
	end
	for _, path in ipairs(entries) do
		local pid_s = path:match("(%d+)%.json$")
		if pid_s then
			local f = io.open(path, "r")
			if f then
				local content = f:read("a")
				f:close()
				local pok, data = pcall(wezterm.json_parse, content)
				if pok and type(data) == "table" then
					sessions[tonumber(pid_s)] = data
				end
			end
		end
	end
	return sessions
end

-- 1 ペインの状態を判定する。claude が居なければ nil。
-- 見つかった claude プロセスの pid も返す(呼び出し側でセッション情報を引くため)
local function detect_pane_agent(pane, procs, claude_pids, claude_status)
	local ok, fg_info = pcall(function()
		return pane:get_foreground_process_info()
	end)
	local fg_pid = ok and fg_info and fg_info.pid

	if fg_pid and procs[fg_pid] then
		local cpid = find_claude_ancestor(fg_pid, procs, claude_pids)
		if cpid then
			return claude_status[cpid] or "idle", cpid
		end
		return nil
	end

	-- pid が取れないペイン(リモートドメイン等)向けのフォールバック
	local path = pane:get_foreground_process_name() or ""
	local name = path:match("([^/]+)$") or path
	if name == "claude" then
		return "idle"
	end
	return nil
end

--- 全ペインを走査してエージェント一覧を返す。結果は CACHE_TTL 秒キャッシュされる
function M.scan()
	local now = os.time()
	if now - cache.timestamp < CACHE_TTL then
		return cache.agents
	end

	local ok, stdout = wezterm.run_child_process({ "ps", "-eo", "pid,ppid,comm" })
	local procs, children, claude_pids = {}, {}, {}
	if ok and stdout then
		for line in stdout:gmatch("[^\n]+") do
			local pid_s, ppid_s, comm = line:match("^%s*(%d+)%s+(%d+)%s+(.+)$")
			if pid_s then
				local pid, ppid = tonumber(pid_s), tonumber(ppid_s)
				local full = comm:gsub("%s+$", "")
				local base = full:match("([^/]+)$") or full
				procs[pid] = { ppid = ppid, name = base }
				children[ppid] = children[ppid] or {}
				table.insert(children[ppid], pid)
				-- 完全一致にすることで Claude.app (Electron) を拾わない
				if base == "claude" then
					claude_pids[pid] = true
				end
			end
		end
	end

	-- Claude Code は作業中だけ caffeinate を子プロセスとして生かしておく
	local claude_status = {}
	for cpid in pairs(claude_pids) do
		local running = false
		for _, child in ipairs(children[cpid] or {}) do
			if procs[child] and procs[child].name == "caffeinate" then
				running = true
				break
			end
		end
		claude_status[cpid] = running and "running" or "idle"
	end

	local sessions = read_sessions()

	local agents, by_pane, seen = {}, {}, {}
	for _, mux_win in ipairs(wezterm.mux.all_windows()) do
		local workspace = mux_win:get_workspace()
		for _, tab in ipairs(mux_win:tabs()) do
			for _, pane in ipairs(tab:panes()) do
				local status, cpid = detect_pane_agent(pane, procs, claude_pids, claude_status)
				if status then
					local session = cpid and sessions[cpid]
					if session and SESSION_STATUS[session.status] then
						status = SESSION_STATUS[session.status]
					end

					local cwd = pane:get_current_working_dir()
					local dir = (cwd and cwd.file_path or "unknown"):gsub("(.)/$", "%1")
					local pane_id = pane:pane_id()

					local a = {
						workspace = workspace,
						pane_id = pane_id,
						project = (session and session.name) or dir:match("([^/]+)$") or dir,
						dir = dir,
						status = status,
					}
					table.insert(agents, a)
					by_pane[pane_id] = status
					seen[pane_id] = true

					local prev = prev_status[pane_id]
					if prev and prev ~= status then
						if prev == "running" and status == "idle" then
							table.insert(events, { agent = a, kind = "completed" })
						elseif status == "waiting" then
							-- running からの質問待ちも、idle からの許可プロンプトも拾う
							table.insert(events, { agent = a, kind = "waiting" })
						end
					end
				end
			end
		end
	end

	-- 消えたペインを prev_status から掃除してから今回の状態を記録
	for pane_id in pairs(prev_status) do
		if not seen[pane_id] then
			prev_status[pane_id] = nil
		end
	end
	for pane_id, status in pairs(by_pane) do
		prev_status[pane_id] = status
	end

	cache.agents = agents
	cache.by_pane = by_pane
	cache.timestamp = now
	return agents
end

--- スキャンを走らせずキャッシュだけ返す (format-tab-title 用)
function M.cached()
	return cache.agents
end

--- キャッシュから 1 ペインの状態を引く。サブプロセスは起動しない
function M.pane_status(pane_id)
	return cache.by_pane[pane_id]
end

--- running 数と総数を返す
function M.summary()
	local running, total = 0, 0
	for _, a in ipairs(cache.agents) do
		total = total + 1
		if a.status == "running" then
			running = running + 1
		end
	end
	return running, total
end

--- 前回呼び出し以降に発生した通知イベントを取り出して空にする。
--- 複数ウィンドウで同じイベントが二重通知されるのを防ぐため drain 方式にしている
function M.take_events()
	local queued = events
	events = {}
	return queued
end

--- ステータスに対応するアイコンを返す
function M.status_icon(status)
	return STATUS_ICON[status] or "?"
end

--- エージェント一覧を InputSelector で開き、選んだペインへジャンプする
function M.dashboard_action()
	return wezterm.action_callback(function(window, pane)
		cache.timestamp = 0 -- 開くときは必ず最新を取る
		local agents = M.scan()
		if #agents == 0 then
			window:toast_notification("wezterm", "Claude Code のセッションはありません", nil, 3000)
			return
		end

		local choices = {}
		for _, a in ipairs(agents) do
			table.insert(choices, {
				label = string.format("%s %s [%s]  %s", STATUS_ICON[a.status] or "?", a.project, a.workspace, a.dir),
				id = tostring(a.pane_id),
			})
		end

		window:perform_action(
			act.InputSelector({
				title = string.format("Claude Code Agents (%d)", #agents),
				choices = choices,
				fuzzy = true,
				action = wezterm.action_callback(function(win, p, id)
					if not id then
						return
					end
					local pane_id = tonumber(id)
					for _, a in ipairs(M.cached()) do
						if a.pane_id == pane_id then
							win:perform_action(act.SwitchToWorkspace({ name = a.workspace }), p)
							break
						end
					end
					local ok, mux_pane = pcall(wezterm.mux.get_pane, pane_id)
					if ok and mux_pane then
						mux_pane:activate()
					end
				end),
			}),
			pane
		)
	end)
end

--- augment-command-palette 用のエントリを返す
function M.palette_entries()
	local agents = M.cached()
	local running = M.summary()

	local entries = {
		{
			brief = #agents == 0 and "Claude Code Agents"
				or string.format("Claude Code Agents (%d agents, %d running)", #agents, running),
			icon = "md_robot",
			action = M.dashboard_action(),
		},
	}
	for _, a in ipairs(agents) do
		table.insert(entries, {
			brief = string.format("Agent %s %s [%s]", STATUS_ICON[a.status] or "?", a.project, a.workspace),
			icon = STATUS_NERD_ICON[a.status] or "md_robot_outline",
			action = wezterm.action_callback(function(win, p)
				win:perform_action(act.SwitchToWorkspace({ name = a.workspace }), p)
				local ok, mux_pane = pcall(wezterm.mux.get_pane, a.pane_id)
				if ok and mux_pane then
					mux_pane:activate()
				end
			end),
		})
	end
	return entries
end

return M
