local M = {}

local function isempty(s)
    return s == nil or s == ""
end

-- Copied function from https://github.com/Almo7aya/openingh.nvim/blob/main/lua/openingh/utils.lua
-- opens a url in the correct OS
local function open_url(url)
  -- order here matters
  -- wsl must come before win
  -- wsl must come before linux

  if vim.fn.has("mac") == 1 then
    vim.fn.system("open " .. url)
    return true
  end

  if vim.fn.has("wsl") == 1 then
    vim.fn.system("explorer.exe " .. url)
    return true
  end

  if vim.fn.has("win64") == 1 or vim.fn.has("win32") == 1 then
    vim.fn.system("start " .. url)
    return true
  end

  if vim.fn.has("linux") == 1 then
    vim.fn.system("xdg-open " .. url)
    return true
  end

  return false
end

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

local function get_git_remote()
    local git_remote0 = vim.api.nvim_exec("!git config --get remote.origin.url", true)
    local git_remote = mysplit(git_remote0, "\n")[2]
    return string.gsub(git_remote, "%.git", "")
end

local function get_git_local()
    local git_local = vim.lsp.buf.list_workspace_folders()
    return git_local[1]
end

local function git_default_branch()
    local git_b_list0 = vim.api.nvim_exec("!git branch", true)
    local git_b_list = mysplit(git_b_list0, "\n")
    table.remove(git_b_list, 1)
    for _, v in pairs(git_b_list) do
        if v:find("*") then
            return mysplit(v, " ")[2]
        end
    end
    return "main"
end

M.browse_file = function()
    local current_file = vim.fn.expand("%")
    local current_dir = vim.api.nvim_exec("pwd", true)
    local git_remote = get_git_remote()
    local git_local = get_git_local()
    local git_hist, _ = string.gsub(git_remote, "com", "githistory.xyz")
    local git_default_branch_str = git_default_branch()
    local _ = vim.fn.system("git rev-parse --is-inside-work-tree")
    if vim.v.shell_error == 0 then
        if not isempty(current_dir) and not isempty(git_local) then
            local relative_path, _ = replace(current_dir, git_local, "")

            local out = git_hist .. "/blob/" .. git_default_branch_str .. relative_path .. "/" .. current_file
            open_url(out)
        elseif not isempty(git_hist) then
            local git_repo = mysplit(git_hist, "/")
            local repo_name = git_repo[#git_repo]
            local relative_to_repo = mysplit(current_dir, "/")
            for i, v in pairs(relative_to_repo) do
                if v == repo_name then
                    local out = git_hist
                    .. "/blob/"
                    .. git_default_branch_str
                    .. "/"
                    .. table.concat(relative_to_repo, "/", i + 1)
                    .. "/"
                    .. current_file
                    open_url(out)
                    break
                end
            end
        end
    else
        print("No git repo found")
    end
end

return M
