local M = {}

local function mysplit(inputstr, sep)
    -- https://stackoverflow.com/a/7615129/10642998
    if sep == nil then
        sep = "%s"
    end
    local t = {}
    for str in string.gmatch(inputstr, "([^" .. sep .. "]+)") do
        table.insert(t, str)
    end
    return t
end

local function replace(str, what, with)
    -- https://stackoverflow.com/a/29379912/10642998
    what = string.gsub(what, "[%(%)%.%+%-%*%?%[%]%^%$%%]", "%%%1") -- escape pattern
    with = string.gsub(with, "[%%]", "%%%%") -- escape replacement
    return string.gsub(str, what, with)
end

M.url = function()
    -- local current_file = vim.api.nvim_get_runtime_file(filename, true)
    local current_file = vim.fn.expand("%")
    local current_dir = vim.api.nvim_exec("pwd", true)
    local git_remote0 = vim.api.nvim_exec("!git config --get remote.origin.url", true)
    local git_remote = mysplit(git_remote0, "\n")[2]
    local git_local0 = vim.lsp.buf.list_workspace_folders()
    local git_local = git_local0[1]
    local git_hist, _ = string.gsub(git_remote, "com", "githistory.xyz")
    local relative_path, _ = replace(current_dir, git_local, "")

    local out = git_hist .. "/blob/main" .. relative_path .. "/" .. current_file
    print(out)
end

M.url()

return M
