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

M.browse_file = function()
    local current_file = vim.fn.expand("%")
    local current_dir = vim.api.nvim_exec("pwd", true)
    local git_remote0 = vim.api.nvim_exec("!git config --get remote.origin.url", true)
    local git_remote = mysplit(git_remote0, "\n")[2]
    local git_remote = string.gsub(git_remote, "%.git", "")
    local git_local0 = vim.lsp.buf.list_workspace_folders()
    local git_local = git_local0[1]
    local git_hist, _ = string.gsub(git_remote, "com", "githistory.xyz")
    if not isempty(current_dir) and not isempty(git_local) then
        local relative_path, _ = replace(current_dir, git_local, "")

        local out = git_hist .. "/blob/main" .. relative_path .. "/" .. current_file
        vim.api.nvim_command("call netrw#BrowseX('" .. out .. "', netrw#CheckIfRemote())")
    elseif not isempty(git_remote) then
        local git_repo = mysplit(git_remote, "/")
        local repo_name = git_repo[#git_repo]
        local relative_to_repo = mysplit(current_dir, "/")
        for i, v in pairs(relative_to_repo) do
            if v == repo_name then
                local out = git_hist
                    .. "/blob/main"
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
