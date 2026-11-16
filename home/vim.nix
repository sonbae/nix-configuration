# vim, ported from github.com/sonbae/dotfiles (.vimrc).
# home-manager builds this into the `vim` wrapper instead of writing ~/.vimrc.
{ pkgs, ... }:

let
  # spacehi highlights tabs and trailing spaces (toggled with `m` below).
  # It isn't in nixpkgs, so build it from the vim-scripts mirror on GitHub.
  spacehi = pkgs.vimUtils.buildVimPlugin {
    pname = "spacehi";
    version = "2010-10-18";
    src = pkgs.fetchFromGitHub {
      owner = "vim-scripts";
      repo = "spacehi.vim";
      rev = "b31478ec512fcd5d86b1e73316edbb96a91c7b4c";
      hash = "sha256-/TOX7VMsnl13F5LFEJO+w/BmrZtbBN7c9OZdI70Dp3s=";
    };
  };
in
{
  programs.vim = {
    enable = true;

    plugins = [ spacehi ];

    settings = {
      number = true;
      relativenumber = true;
      tabstop = 4;
      shiftwidth = 4;
      expandtab = false;
    };

    extraConfig = ''
      filetype plugin indent on
      syntax on
      set title

      set showcmd
      set incsearch
      set hlsearch

      set smarttab
      set softtabstop=4
      set autoindent
      set smartindent

      " disable arrow keys
      imap <up> <nop>
      imap <down> <nop>
      imap <left> <nop>
      imap <right> <nop>
      map <up> <nop>
      map <down> <nop>
      map <left> <nop>
      map <right> <nop>

      " move between splits with Ctrl-<vim keys>
      nmap <silent> <C-k> :wincmd k<CR>
      nmap <silent> <C-j> :wincmd j<CR>
      nmap <silent> <C-h> :wincmd h<CR>
      nmap <silent> <C-l> :wincmd l<CR>

      " save a file you opened without sudo
      cmap w!! w !sudo tee > /dev/null %

      " clear search highlighting with Enter
      nnoremap <Enter> :noh<CR>

      " toggle whitespace highlighting (spacehi)
      map m :ToggleSpaceHi<CR>
      let g:spacehi_tabcolor="ctermfg=blue ctermbg=blue guifg=blue guibg=blue"
      let g:spacehi_spacecolor="ctermfg=Black ctermbg=Yellow guifg=Blue guibg=Yellow"
      let g:spacehi_nbspcolor="ctermfg=White ctermbg=Red guifg=White guibg=Red"
    '';
  };
}
