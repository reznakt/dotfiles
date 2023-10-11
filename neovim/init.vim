" ----------------------------------------------------------------- "
"               init.vim - Neovim editor configuration              "
"                                                                   "
"                            Tomáš Režňák                           "
"                                                                   "
"                              03/2022                              "
" ----------------------------------------------------------------- "

" neovim-specific settings
set runtimepath^=~/.nvim runtimepath+=~/.nvim/after
let &packpath = &runtimepath


" ----------------------------------------------------------------- "
"                         General settings                          "
" ----------------------------------------------------------------- "

set nocompatible
set encoding=utf-8

syntax on

set noerrorbells
set tabstop=4 softtabstop=4
set smarttab
set shiftwidth=4
set shiftround
set expandtab
set smartindent
set number
set nowrap
set ignorecase
set smartcase
set noswapfile
set nobackup
set undodir=~/.nvim/undodir
set undofile
set incsearch
set cursorline
set hlsearch
set wildmenu
set wildmode=full
set mouse=a
set mousemodel=popup
set title
set autoread
set noshowmode
set signcolumn=yes
set backspace=indent,eol,start
set updatetime=50

" limit number of suggestions in COC
set pumheight=20

" enable true colors
if (has('nvim'))
  let $NVIM_TUI_ENABLE_TRUE_COLOR = 1
endif

if (has('termguicolors'))
  set termguicolors
endif

" fix italics
if !has('nvim')
  let &t_ZH="\e[3m"
  let &t_ZR="\e[23m"
endif


" ----------------------------------------------------------------- "
"                          Auto-commands                            "
" ----------------------------------------------------------------- "

" install vim-plug if not found
if empty(glob($HOME . '/.nvim/autoload/plug.vim'))
  silent !curl -fLo ~/.nvim/autoload/plug.vim --create-dirs
    \ 'https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
endif

" run PlugInstall if there are missing plugins
augroup PLUG_INSTALL
    autocmd!
    autocmd VimEnter * if len(filter(values(g:plugs), '!isdirectory(v:val.dir)'))
        \| PlugInstall --sync | source $MYVIMRC
        \| endif
augroup END

" restore cursor caret to blinking underline at exit
augroup RESTORE_CURSOR
    autocmd!
    autocmd VimLeave * let &t_SI = "\<Esc>]50;CursorShape=1\x7"
augroup END


" ----------------------------------------------------------------- "
"                            Plug-ins                               "
" ----------------------------------------------------------------- "

" start vim-plug plugin declarations
call plug#begin($HOME . '/.nvim/plugged')

Plug 'nvim-treesitter/nvim-treesitter'                                    " advanced language-dependent syntax highlighting
Plug 'kvngvikram/rightclick-macros'                                       " right-click context menu with copy, cut, paste and other options
Plug 'nvim-lualine/lualine.nvim'                                          " bottom status line
Plug 'neoclide/coc.nvim', {'branch': 'release'}                           " code completion, snippets, and other
Plug 'kaicataldo/material.vim'                                            " material theme
Plug 'akinsho/toggleterm.nvim'                                            " toggle-able terminal
Plug 'm-demare/hlargs.nvim'                                               " function argument highlighting for treesitter
Plug 'sunjon/shade.nvim'                                                  " darker inactive buffers
Plug 'editorconfig/editorconfig-vim'                                      " support for .editorconfig files
Plug 'nvim-tree/nvim-web-devicons'                                        " filetype icons
Plug 'romgrk/barbar.nvim'                                                 " buffer tabs
Plug 'lewis6991/gitsigns.nvim'                                            " git diff lines in the gutter, blame and more
Plug 'tpope/vim-sleuth'                                                   " automatically determines indentation and other settings from environment
Plug 'tpope/vim-fugitive'                                                 " git commands
Plug 'nvim-lua/plenary.nvim'                                              " required by octo.nvim
Plug 'nvim-telescope/telescope.nvim'                                      " required by octo.nvim
Plug 'pwntester/octo.nvim'                                                " github-cli
Plug 'osyo-manga/vim-brightest'                                           " highlight matching words
Plug 'norcalli/nvim-colorizer.lua'                                        " render RGB colors
Plug 'mg979/vim-visual-multi', {'branch': 'master'}                       " multiple cursors
Plug 'lukas-reineke/indent-blankline.nvim', {'tag': 'v2.20.8'}            " indent guides
Plug 'github/copilot.vim'                                                 " Github Copilot (AI code completion)
Plug 'iamcco/markdown-preview.nvim', { 'do': 'cd app && yarn install' }   " live markdown preview in the browser

call plug#end()

" COC extensions
let g:coc_global_extensions = ['coc-pairs', 'coc-python', 'coc-vimlsp', 'coc-clangd', 'coc-dot-complete', 'coc-snippets', 'coc-sh', 'coc-highlight', 'coc-prettier', 'coc-json', 'coc-yaml', 'coc-tsserver', 'coc-markdownlint', 'coc-eslint', 'coc-css', 'coc-html', 'coc-emmet', 'coc-git', 'coc-yank', 'coc-toml', 'coc-cmake']

" select material darker theme
let g:material_terminal_italics = 1 | let g:material_theme_style = 'darker' | colorscheme material

" disable ultest deprecation notice
let g:ultest_deprecation_notice = 0


" ----------------------------------------------------------------- "
"                          Key mappings                             "
" ----------------------------------------------------------------- "

" enable highlighting of all text using Ctrl+A
nnoremap <C-a> ggVG

" enable arrow keys in wildmenu
set wildcharm=<C-Z>
cnoremap <expr> <up> wildmenumode() ? "\<left>" : "\<up>"
cnoremap <expr> <down> wildmenumode() ? "\<right>" : "\<down>"
cnoremap <expr> <left> wildmenumode() ? "\<up>" : "\<left>"
cnoremap <expr> <right> wildmenumode() ? " \<bs>\<C-Z>" : "\<right>"

" toggle terminal with F2
map <F2> :ToggleTerm<CR>

" COC setup
"
" Make <CR> to accept selected completion item or notify coc.nvim to format
" <C-g>u breaks current undo, please make your own choice.
inoremap <silent><expr> <TAB> coc#pum#visible() ? coc#pum#confirm()
                              \: "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"

function! CheckBackspace() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

" Use <c-space> to trigger completion.
if has('nvim')
  inoremap <silent><expr> <c-space> coc#refresh()
else
  inoremap <silent><expr> <c-@> coc#refresh()
endif

" Use `[g` and `]g` to navigate diagnostics
" Use `:CocDiagnostics` to get all diagnostics of current buffer in location list.
nmap <silent> [g <Plug>(coc-diagnostic-prev)
nmap <silent> ]g <Plug>(coc-diagnostic-next)

" GoTo code navigation.
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

" Use K to show documentation in preview window.
nnoremap <silent> K :call ShowDocumentation()<CR>

function! ShowDocumentation()
  if CocAction('hasProvider', 'hover')
    call CocActionAsync('doHover')
  else
    call feedkeys('K', 'in')
  endif
endfunction

" Highlight the symbol and its references when holding the cursor.
autocmd CursorHold * silent call CocActionAsync('highlight')

" Symbol renaming.
nmap <leader>rn <Plug>(coc-rename)

" Formatting selected code.
xmap <leader>f  <Plug>(coc-format-selected)
nmap <leader>f  <Plug>(coc-format-selected)

augroup mygroup
  autocmd!
  " Setup formatexpr specified filetype(s).
  autocmd FileType typescript,json setl formatexpr=CocAction('formatSelected')
  " Update signature help on jump placeholder.
  autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
augroup end

" Applying codeAction to the selected region.
" Example: `<leader>aap` for current paragraph
xmap <leader>a  <Plug>(coc-codeaction-selected)
nmap <leader>a  <Plug>(coc-codeaction-selected)

" Remap keys for applying codeAction to the current buffer.
nmap <leader>ac  <Plug>(coc-codeaction)
" Apply AutoFix to problem on the current line.
nmap <leader>qf  <Plug>(coc-fix-current)

" Run the Code Lens action on the current line.
nmap <leader>cl  <Plug>(coc-codelens-action)

" Map function and class text objects
" NOTE: Requires 'textDocument.documentSymbol' support from the language server.
xmap if <Plug>(coc-funcobj-i)
omap if <Plug>(coc-funcobj-i)
xmap af <Plug>(coc-funcobj-a)
omap af <Plug>(coc-funcobj-a)
xmap ic <Plug>(coc-classobj-i)
omap ic <Plug>(coc-classobj-i)
xmap ac <Plug>(coc-classobj-a)
omap ac <Plug>(coc-classobj-a)

" Remap <C-f> and <C-b> for scroll float windows/popups.
if has('nvim-0.4.0') || has('patch-8.2.0750')
  nnoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"
  nnoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"
  inoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(1)\<cr>" : "\<Right>"
  inoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(0)\<cr>" : "\<Left>"
  vnoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"
  vnoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"
endif

" Use CTRL-S for selections ranges.
" Requires 'textDocument/selectionRange' support of language server.
nmap <silent> <C-s> <Plug>(coc-range-select)
xmap <silent> <C-s> <Plug>(coc-range-select)

" Add `:Format` command to format current buffer.
command! -nargs=0 Format :call CocActionAsync('format')

" Add `:Fold` command to fold current buffer.
command! -nargs=? Fold :call     CocAction('fold', <f-args>)

" Add `:OR` command for organize imports of the current buffer.
command! -nargs=0 OR   :call     CocActionAsync('runCommand', 'editor.action.organizeImport')

" Add (Neo)Vim's native statusline support.
" NOTE: Please see `:h coc-status` for integrations with external plugins that
" provide custom statusline: lightline.vim, vim-airline.
set statusline^=%{coc#status()}%{get(b:,'coc_current_function','')}

" Mappings for CoCList
" Show all diagnostics.
nnoremap <silent><nowait> <space>a  :<C-u>CocList diagnostics<cr>
" Manage extensions.
nnoremap <silent><nowait> <space>e  :<C-u>CocList extensions<cr>
" Show commands.
nnoremap <silent><nowait> <space>c  :<C-u>CocList commands<cr>
" Find symbol of current document.
nnoremap <silent><nowait> <space>o  :<C-u>CocList outline<cr>
" Search workspace symbols.
nnoremap <silent><nowait> <space>s  :<C-u>CocList -I symbols<cr>
" Do default action for next item.
nnoremap <silent><nowait> <space>j  :<C-u>CocNext<CR>
" Do default action for previous item.
nnoremap <silent><nowait> <space>k  :<C-u>CocPrev<CR>
" Resume latest coc list.
nnoremap <silent><nowait> <space>p  :<C-u>CocListResume<CR>


" ----------------------------------------------------------------- "
"                   LUA-based plugin configs                        "
" ----------------------------------------------------------------- "

lua << END

-- initialize plugins which do not require configuration
require('hlargs').setup()
require('toggleterm').setup()
require('gitsigns').setup()
require("octo").setup()
require('colorizer').setup()

-- lualine setup
require('lualine').setup {
    options = {
        icons_enabled = false,
        theme = 'codedark',
        component_separators = {left = '', right = '|'},
        section_separators = {left = '', right = ''},
        disabled_filetypes = {},
        always_divide_middle = true,
    },

    sections = {
        lualine_a = {
            'mode'
        },

        lualine_b = {
            {'branch', icons_enabled = true, icon = '⎇  '},
            'diff', 
            {'diagnostics', sources = {'coc'}, update_in_insert = true}
        },

        lualine_c = {
            {'filename', file_status = true, path = 2, shorting_target = 40}
        },

        lualine_x = {
            {'encoding', fmt = function(str) return str:upper() end}, 
            {'fileformat', fmt = function(str) return str:upper() end}, 
            {'filetype', fmt = function(str) return str:gsub('^%l', string.upper) end}, 
            {'filesize', fmt = function(str) return str:upper() end}
        },

        lualine_y = {
            'progress'
        },

        lualine_z = {
            'location'
        }
    },

    inactive_sections = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = {'filename'},
        lualine_x = {'location'},
        lualine_y = {},
        lualine_z = {}
    },

    tabline = {},
    extensions = {}
}

-- treesitter setup
require('nvim-treesitter.configs').setup {
    ensure_installed = 'all',
    sync_install = false,

    highlight = {
        enable = true,
        disable = {},
        additional_vim_regex_highlighting = false
    }

}

function _G.set_terminal_keymaps()
  local opts = {buffer = 0}
  vim.keymap.set('t', '<esc>', [[<C-\><C-n>]], opts)
  vim.keymap.set('t', 'jk', [[<C-\><C-n>]], opts)
  vim.keymap.set('t', '<C-h>', [[<Cmd>wincmd h<CR>]], opts)
  vim.keymap.set('t', '<C-j>', [[<Cmd>wincmd j<CR>]], opts)
  vim.keymap.set('t', '<C-k>', [[<Cmd>wincmd k<CR>]], opts)
  vim.keymap.set('t', '<C-l>', [[<Cmd>wincmd l<CR>]], opts)
end

vim.cmd('autocmd! TermOpen term://* lua set_terminal_keymaps()')

-- shade setup
require('shade').setup {
  overlay_opacity = 50,
  opacity_step = 1,
  keys = {
    brightness_up    = '<C-Up>',
    brightness_down  = '<C-Down>',
    toggle           = '<Leader>s',
  }
}

-- gitsigns setup
require('gitsigns').setup {
    current_line_blame = true
}

-- use make to compile all treesitter parsers
for _, parser in ipairs(require('nvim-treesitter.parsers').get_parser_configs()) do
  parser.install_info.use_makefile = true
end

-- indent guides setup
require("indent_blankline").setup {
    space_char_blankline = " ",
}

END

