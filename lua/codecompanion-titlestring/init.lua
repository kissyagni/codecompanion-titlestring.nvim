--- Show CodeCompanion agent status in the terminal title bar.
--- Requires olimorris/codecompanion.nvim (listens to its User autocommands).

local config = require("codecompanion-titlestring.config")

local M = {}

---@type CodeCompanionTitlestringConfig?
local cfg

---@enum State
local State = {
	Idle = "idle",
	Processing = "processing",
	Compacting = "compacting",
	Approval = "approval",
	Question = "question",
}

---@type State?
local currentState = State.Idle
local base_titlestring = ""
local timer = nil
local spinner_idx = 1

function M.update()
	if not cfg then
		return
	end

	local icon
	if currentState == State.Approval then
		icon = cfg.icons.approval
	elseif currentState == State.Question then
		icon = cfg.icons.question
	elseif currentState == State.Compacting then
		local icons = cfg.icons.compacting
		icon = type(icons) == "string" and icons or icons[spinner_idx % #icons + 1]
	elseif currentState == State.Processing then
		local icons = cfg.icons.thinking
		icon = type(icons) == "string" and icons or icons[spinner_idx % #icons + 1]
	else
		icon = cfg.icons.idle
	end

	vim.opt.titlestring = icon .. base_titlestring
end

local function start_timer()
	if timer or not cfg then
		return
	end

	timer = vim.uv.new_timer()
	if not timer then
		return
	end

	timer:start(
		0,
		500,
		vim.schedule_wrap(function()
			spinner_idx = spinner_idx + 1
			M.update()
		end)
	)
end

local function stop_timer()
	spinner_idx = 1
	if timer then
		timer:stop()
		timer:close()
		timer = nil
	end
end

local function set_state(state)
	if not cfg then
		return
	end

	currentState = state
	if currentState == State.Compacting then
		start_timer()
	elseif currentState == State.Processing then
		start_timer()
	else
		stop_timer()
	end

	M.update()
end

local AUGROUP = "codecompanion_titlestring"

---@param opts? CodeCompanionTitlestringConfig
function M.setup(opts)
	cfg = config.setup(opts)

	base_titlestring = cfg.titlestring or vim.o.titlestring

	vim.o.title = true

	M.update()

	local group = vim.api.nvim_create_augroup(AUGROUP, { clear = true })

	vim.api.nvim_create_autocmd({ "BufEnter", "DirChanged" }, {
		group = group,
		callback = function()
			if currentState == State.Idle then
				M.update()
			end
		end,
		desc = "Refresh terminal title when agent is idle",
	})

	vim.api.nvim_create_autocmd("User", {
		group = group,
		pattern = "CodeCompanionChatSubmitted",
		callback = function()
			set_state(State.Processing)
		end,
		desc = "Show AI icon while chat agent is working",
	})

	vim.api.nvim_create_autocmd("User", {
		group = group,
		pattern = "CodeCompanionChatDone,CodeCompanionChatStopped",
		callback = function()
			set_state(State.Idle)
		end,
		desc = "Restore terminal title when chat agent finishes",
	})

	vim.api.nvim_create_autocmd("User", {
		group = group,
		pattern = "CodeCompanionRequestStarted",
		callback = function(args)
			local interaction = (args.data or {}).interaction
			if interaction ~= "chat" then
				set_state(State.Processing)
			end
		end,
		desc = "Show AI icon for non-chat CodeCompanion requests",
	})

	vim.api.nvim_create_autocmd("User", {
		group = group,
		pattern = "CodeCompanionRequestFinished",
		callback = function(args)
			local interaction = (args.data or {}).interaction
			if interaction ~= "chat" then
				set_state(State.Idle)
			end
		end,
		desc = "Restore terminal title when non-chat requests finish",
	})

	vim.api.nvim_create_autocmd("User", {
		group = group,
		pattern = "CodeCompanionChatCompacting",
		callback = function()
			set_state(State.Compacting)
		end,
		desc = "Show compacting status in terminal title",
	})

	vim.api.nvim_create_autocmd("User", {
		group = group,
		pattern = "CodeCompanionToolApprovalRequested,CodeCompanionCLIApprovalRequested",
		callback = function()
			set_state(State.Approval)
		end,
		desc = "Show approval icon in terminal title",
	})

	vim.api.nvim_create_autocmd("User", {
		group = group,
		pattern = "CodeCompanionToolApprovalFinished,CodeCompanionCLIApprovalFinished",
		callback = function()
			set_state(State.Processing)
		end,
		desc = "Clear approval icon in terminal title",
	})

	vim.api.nvim_create_autocmd("User", {
		group = group,
		pattern = "CodeCompanionToolQuestionAsked",
		callback = function()
			set_state(State.Question)
		end,
		desc = "Show input icon in terminal title",
	})

	vim.api.nvim_create_autocmd("User", {
		group = group,
		pattern = "CodeCompanionToolQuestionAnswered",
		callback = function()
			set_state(State.Processing)
		end,
		desc = "Clear input icon in terminal title",
	})
end

return M
