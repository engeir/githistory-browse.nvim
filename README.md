# githistory-browse.nvim

> This is still a work in progress

Quickly preview files in [githistory.xyz]!

## Installation

```viml
Plug 'engeir/githistory-browse.nvim'
```

Then make the command available by calling `require"githistory-browse"` from your
`init.vim`/`init.lua`.

## Usage

The plugin adds the function `GhBrowse`. You can for example make a little remap for it:

```viml
nnoremap <leader>GH :GhBrowse<CR>
```

[githistory.xyz]: https://githistory.xyz/
