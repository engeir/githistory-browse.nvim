local M = {}

local function isempty(s)
    return s == nil or s == ""
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
    for i, v in pairs(git_b_list) do
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
    local git_default_branch = git_default_branch()
    if not isempty(current_dir) and not isempty(git_local) then
        local relative_path, _ = replace(current_dir, git_local, "")

        local out = git_hist .. "/blob/" .. git_default_branch .. relative_path .. "/" .. current_file
        vim.api.nvim_command("call netrw#BrowseX('" .. out .. "', netrw#CheckIfRemote())")
    elseif not isempty(git_hist) then
        local git_repo = mysplit(git_hist, "/")
        local repo_name = git_repo[#git_repo]
        local relative_to_repo = mysplit(current_dir, "/")
        for i, v in pairs(relative_to_repo) do
            if v == repo_name then
                local out = git_hist
                    .. "/blob/"
                    .. git_default_branch
                    .. "/"
                    .. table.concat(relative_to_repo, "/", i + 1)
                    .. "/"
                    .. current_file
                vim.api.nvim_command("call netrw#BrowseX('" .. out .. "', netrw#CheckIfRemote())")
                break
            end
        end
    else
        local out = ""
        print("No git repo found")
    end
    return out
end

vim.api.nvim_add_user_command("GhBrowse", M.browse_file, {})

return M
