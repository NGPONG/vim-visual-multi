"script to handle compatibility issues with other plugins

fun! vm#comp#init()
    """Set variables according to plugin needs."""
    if exists('g:loaded_youcompleteme')
        let g:VM_use_first_cursor_in_line = 1
    endif
endfun

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

fun! vm#comp#TextChangedI()
    if exists('g:loaded_deoplete')
        call deoplete#custom#buffer_option('auto_complete', v:true)
    endif
endfun

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

fun! vm#comp#icmds()
    if exists('g:loaded_deoplete')
        call deoplete#custom#buffer_option('auto_complete', v:false)
    endif
endfun

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

fun! vm#comp#reset()
    if exists('g:loaded_deoplete')
        call deoplete#custom#buffer_option('auto_complete', v:true)
    endif
endfun

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" don't reindent for filetypes

fun! vm#comp#reindents()
    return g:VM_no_reindent_filetype + ['ctrlsf']
endfun
