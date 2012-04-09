" schemery.vim - Rotate vim color schemes
" Version:      1.0

if v:version < 700 || exists('loaded_schemery') || &cp
    finish
endif

let loaded_schemery = 1
let s:schemes = []

function! s:Schemery(args)
    if len(a:args) == 0
        let i = 0
        while i < len(s:schemes)
            echo '  '.join(map(s:schemes[i : i+4], 'printf("%-14s", v:val)'))
            let i += 5
        endwhile
    elseif a:args == 'all'
        let paths = split(globpath(&runtimepath, 'colors/*.vim'), "\n")
        let s:schemes = map(paths, 'fnamemodify(v:val, ":t:r")')
    else
        let s:schemes = split(a:args)
    endif
endfunction
command! -nargs=* Schemery call <SID>Schemery('<args>')

function! s:PickScheme(how)
    if len(s:schemes) == 0
        call s:Schemery('all')
    endif
    if exists('g:colors_name')
        let current = index(s:schemes, g:colors_name)
    else
        let current = -1
    endif
    let missing = []
    let how = a:how
    for i in range(len(s:schemes))
        if how == 0
            let current = localtime() % len(s:schemes)
            let how = 1  " in case random scheme does not exist
        else
            let current += how
            if !(0 <= current && current < len(s:schemes))
                let current = (how>0 ? 0 : len(s:schemes)-1)
            endif
        endif
        try
            execute 'colorscheme '.s:schemes[current]
            break
        catch /E185:/
            call add(missing, s:schemes[current])
        endtry
    endfor
    redraw
    if len(missing) > 0
        echo 'Error: colorscheme not found:' join(missing)
    endif
    if exists('g:colors_name')
        echo g:colors_name
    endif
endfunction

nnoremap <silent> <Plug>schemeNext :<C-U>call <SID>PickScheme(1)<CR>
nnoremap <silent> <Plug>schemePrev :<C-U>call <SID>PickScheme(-1)<CR>
nnoremap <silent> <Plug>schemeRand :<C-U>call <SID>PickScheme(0)<CR>

nmap ]C <Plug>schemeNext
nmap [C <Plug>schemePrev
