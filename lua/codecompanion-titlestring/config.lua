---@class CodeCompanionTitlestringIcons
---@field idle string
---@field thinking string[]
---@field approval string
---@field question string
---@field compacting string

---@class CodeCompanionTitlestringConfig
---@field icons CodeCompanionTitlestringIcons

local M = {}

---@type CodeCompanionTitlestringConfig
M.defaults = {
	icons = {
		idle = " ",
		thinking = { "󰚩", "󱚝" },
		approval = "󰚩 󰭺 ",
		question = "󰚩 󱜸 ",
		compacting = "󱜙 ",
	},
}

---@param opts? CodeCompanionTitlestringConfig
---@return CodeCompanionTitlestringConfig
function M.setup(opts)
	return vim.tbl_deep_extend("force", vim.deepcopy(M.defaults), opts or {})
end

return M
