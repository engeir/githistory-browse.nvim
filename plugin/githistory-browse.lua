local ghbrowse = require("githistory-browse")

-- vim.api.nvim_create_user_command("OpenInGHFile", function()
--   ghbrowse:openFile()
-- end, {})

-- vim.api.nvim_create_user_command("GhBrowse", function() ghbrowse.browse_file end, {})

vim.api.nvim_create_user_command("GhBrowse", ghbrowse.browse_file, {})
-- vim.api.nvim_create_user_command("OpenInGHRepo", function()
--   ghbrowse:openRepo()
-- end, {})
