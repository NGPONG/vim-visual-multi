""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"Set up highlighting
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

let s:Themes = {}

augroup VM_reset_theme
  au!
  au ColorScheme * call vm#themes#init()
augroup END


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
fun! s:handle_highlight(group) abort
  let out = execute('highlight ' . a:group)
  if match(out, ' links to ') >= 0
    let hi = substitute(out, '^.*links to ', '', '')
    return "link " . a:group . " " . hi
  else
    let hi = strtrans(substitute(out, '^.*xxx ', '', ''))
    let hi = substitute(hi, '\^.', '', 'g')
    return a:group . " " . substitute(hi, '\^.', '', 'g')
  endif
endfun

fun! vm#themes#init() abort
  if !exists('g:Vm') | return | endif

  if !empty(g:VM_highlight_matches)
    let g:Vm.search_hi = s:handle_highlight('Search')
    call vm#themes#search_highlight()
  endif

  if !empty(g:VM_highlight_incmatches)
    let g:Vm.incsearch_hi = s:handle_highlight('IncSearch')
    call vm#themes#incsearch_highlight()
  endif

  let theme = get(g:, 'VM_theme', '')

  if theme == 'default'
    hi! link VM_Mono ErrorMsg
    hi! link VM_Cursor Visual
    hi! link VM_Extend PmenuSel
    hi! link VM_Insert DiffChange
    hi! link MultiCursor VM_Cursor

  elseif has_key(s:Themes, theme)
    call s:Themes[theme]()
  endif
endfun

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

fun! vm#themes#search_highlight() abort
  " Init Search highlight.
  let hl = g:VM_highlight_matches
  let g:Vm.Search = hl == 'underline' ? 'Search term=underline cterm=underline gui=underline' :
        \           hl == 'red'       ? 'Search ctermfg=196 guifg=#ff0000' :
        \           hl =~ '^hi!\? '   ? substitute(g:VM_highlight_matches, '^hi!\?', '', '')
        \                             : 'Search term=underline cterm=underline gui=underline'
endfun

fun! vm#themes#incsearch_highlight() abort
  " Init IncSearch highlight.
  let hl = g:VM_highlight_incmatches
  let g:Vm.IncSearch = hl == 'underline' ? 'IncSearch term=underline cterm=underline gui=underline' :
        \           hl == 'red'       ? 'IncSearch ctermfg=196 guifg=#ff0000' :
        \           hl =~ '^hi!\? '   ? substitute(g:VM_highlight_incmatches, '^hi!\?', '', '')
        \                             : 'IncSearch term=underline cterm=underline gui=underline'
endfun

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

fun! vm#themes#load(theme) abort
  " Load a theme or set default.
  if empty(a:theme) || a:theme == 'default'
    let g:VM_theme = 'default'
  elseif index(keys(s:Themes), a:theme) < 0
    echo "No such theme."
    return
  else
    let g:VM_theme = a:theme
  endif
  call vm#themes#init()
endfun

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

fun! vm#themes#complete(A, L, P) abort
  let valid = &background == 'light' ? s:Themes._light : s:Themes._dark
  return filter(sort(copy(valid)), 'v:val=~#a:A')
endfun

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

fun! vm#themes#statusline() abort
  if !exists('b:visual_multi')
    return ''
  endif
  let v = b:VM_Selection.Vars
  let vm = VMInfos()
  let color  = '%#VM_Extend#'
  let single = b:VM_Selection.Vars.single_region ? '%#VM_Mono# SINGLE ' : ''
  try
    if v.insert
      if b:VM_Selection.Insert.replace
        let [ mode, color ] = [ 'V-R', '%#VM_Mono#' ]
      else
        let [ mode, color ] = [ 'V-I', '%#VM_Cursor#' ]
      endif
    else
      let mode = { 'n': 'V-M', 'v': 'V', 'V': 'V-L', "\<C-v>": 'V-B' }[mode()]
    endif
  catch
    let mode = 'V-M'
  endtry
  let mode = exists('v.statusline_mode') ? v.statusline_mode : mode
  let patterns = string(vm.patterns)[:(winwidth(0)-30)]
  return printf("%s %s %s %s %s%s %s %%=%%l:%%c %s %s",
        \ color, mode, '%#VM_Insert#', vm.ratio, single, '%#TabLine#',
        \ patterns, color, vm.status . ' ')
endfun

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

let s:Themes._light = ['sand', 'paper', 'lightblue1', 'lightblue2', 'lightpurple1', 'lightpurple2']
let s:Themes._dark = ['iceblue', 'ocean', 'neon', 'purplegray', 'nord', 'codedark', 'spacegray', 'olive', 'sand']

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

fun! s:Themes.iceblue()
  hi! VM_Extend ctermbg=24                   guibg=#005f87
  hi! VM_Cursor ctermbg=31    ctermfg=237    guibg=#0087af    guifg=#87dfff
  hi! VM_Insert ctermbg=239                  guibg=#4c4e50
  hi! VM_Mono   ctermbg=180   ctermfg=235    guibg=#dfaf87    guifg=#262626
endfun

fun! s:Themes.ocean()
  hi! VM_Extend ctermbg=25                   guibg=#005faf
  hi! VM_Cursor ctermbg=39    ctermfg=239    guibg=#87afff    guifg=#4e4e4e
  hi! VM_Insert ctermbg=239                  guibg=#4c4e50
  hi! VM_Mono   ctermbg=186   ctermfg=239    guibg=#dfdf87    guifg=#4e4e4e
endfun

fun! s:Themes.neon()
  hi! VM_Extend ctermbg=26    ctermfg=109    guibg=#005fdf    guifg=#89afaf
  hi! VM_Cursor ctermbg=39    ctermfg=239    guibg=#00afff    guifg=#4e4e4e
  hi! VM_Insert ctermbg=239                  guibg=#4c4e50
  hi! VM_Mono   ctermbg=221   ctermfg=239    guibg=#ffdf5f    guifg=#4e4e4e
endfun

fun! s:Themes.lightblue1()
  hi! VM_Extend ctermbg=153                  guibg=#afdfff
  hi! VM_Cursor ctermbg=111   ctermfg=239    guibg=#87afff    guifg=#4e4e4e
  hi! VM_Insert ctermbg=180   ctermfg=235    guibg=#dfaf87    guifg=#262626
  hi! VM_Mono   ctermbg=167   ctermfg=253    guibg=#df5f5f    guifg=#dadada cterm=bold term=bold gui=bold
endfun

fun! s:Themes.lightblue2()
  hi! VM_Extend ctermbg=117                  guibg=#87dfff
  hi! VM_Cursor ctermbg=111   ctermfg=239    guibg=#87afff    guifg=#4e4e4e
  hi! VM_Insert ctermbg=180   ctermfg=235    guibg=#dfaf87    guifg=#262626
  hi! VM_Mono   ctermbg=167   ctermfg=253    guibg=#df5f5f    guifg=#dadada cterm=bold term=bold gui=bold
endfun

fun! s:Themes.purplegray()
  hi! VM_Extend ctermbg=60                   guibg=#544a65
  hi! VM_Cursor ctermbg=103   ctermfg=54     guibg=#8787af    guifg=#5f0087
  hi! VM_Insert ctermbg=239                  guibg=#4c4e50
  hi! VM_Mono   ctermbg=141   ctermfg=235    guibg=#af87ff    guifg=#262626
endfun

fun! s:Themes.nord()
  hi! VM_Extend ctermbg=239                  guibg=#434C5E
  hi! VM_Cursor ctermbg=245   ctermfg=24     guibg=#8a8a8a    guifg=#005f87
  hi! VM_Insert ctermbg=239                  guibg=#4c4e50
  hi! VM_Mono   ctermbg=131   ctermfg=235    guibg=#AF5F5F    guifg=#262626
endfun

fun! s:Themes.codedark()
  hi! VM_Extend ctermbg=242                  guibg=#264F78
  hi! VM_Cursor ctermbg=239   ctermfg=252    guibg=#6A7D89    guifg=#C5D4DD
  hi! VM_Insert ctermbg=239                  guibg=#4c4e50
  hi! VM_Mono   ctermbg=131   ctermfg=235    guibg=#AF5F5F    guifg=#262626
endfun

fun! s:Themes.spacegray()
  hi! VM_Extend ctermbg=237                  guibg=#404040
  hi! VM_Cursor ctermbg=242   ctermfg=239    guibg=Grey50     guifg=#4e4e4e
  hi! VM_Insert ctermbg=239                  guibg=#4c4e50
  hi! VM_Mono   ctermbg=131   ctermfg=235    guibg=#AF5F5F    guifg=#262626
endfun

fun! s:Themes.sand()
  hi! VM_Extend ctermbg=143   ctermfg=0      guibg=darkkhaki  guifg=black
  hi! VM_Cursor ctermbg=64    ctermfg=186    guibg=olivedrab  guifg=khaki
  hi! VM_Insert ctermbg=239                  guibg=#4c4e50
  hi! VM_Mono   ctermbg=131   ctermfg=235    guibg=#AF5F5F    guifg=#262626
endfun

fun! s:Themes.paper()
  hi! VM_Extend ctermbg=250   ctermfg=16     guibg=#bfbcaf    guifg=black
  hi! VM_Cursor ctermbg=239   ctermfg=188    guibg=#4c4e50    guifg=#d8d5c7
  hi! VM_Insert ctermbg=167   ctermfg=253    guibg=#df5f5f    guifg=#dadada cterm=bold term=bold gui=bold
  hi! VM_Mono   ctermbg=16    ctermfg=188    guibg=#000000    guifg=#d8d5c7
endfun

fun! s:Themes.olive()
  hi! VM_Extend ctermbg=3     ctermfg=0      guibg=olive      guifg=black
  hi! VM_Cursor ctermbg=64    ctermfg=186    guibg=olivedrab  guifg=khaki
  hi! VM_Insert ctermbg=239                  guibg=#4c4e50
  hi! VM_Mono   ctermbg=131   ctermfg=235    guibg=#AF5F5F    guifg=#262626
endfun

fun! s:Themes.lightpurple1()
  hi! VM_Extend ctermbg=225                  guibg=#ffdfff
  hi! VM_Cursor ctermbg=183   ctermfg=54     guibg=#dfafff    guifg=#5f0087 cterm=bold term=bold gui=bold
  hi! VM_Insert ctermbg=146   ctermfg=235    guibg=#afafdf    guifg=#262626
  hi! VM_Mono   ctermbg=135   ctermfg=225    guibg=#af5fff    guifg=#ffdfff cterm=bold term=bold gui=bold
endfun

fun! s:Themes.lightpurple2()
  hi! VM_Extend ctermbg=189                  guibg=#dfdfff
  hi! VM_Cursor ctermbg=183   ctermfg=54     guibg=#dfafff    guifg=#5f0087 cterm=bold term=bold gui=bold
  hi! VM_Insert ctermbg=225   ctermfg=235    guibg=#ffdfff    guifg=#262626
  hi! VM_Mono   ctermbg=135   ctermfg=225    guibg=#af5fff    guifg=#ffdfff cterm=bold term=bold gui=bold
endfun

" vim: et ts=2 sw=2 sts=2 :
