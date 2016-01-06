" functions
" 	s:switchWindow(bufNr)	switch to window that displays buffer bufNr
" 	ToggleScratch()			toggle scratch buffer display

if exists('loaded_scratch') || &cp
    finish
endif

"autocmd BufNewFile __Scratch__ call s:makeBufferScratch()
command! -nargs=0 -bar ScratchToggle call s:scratchToggle()

let loaded_scratch=1
let scratchBufName = "__Scratch__"
let scratchWinWidth = 60

" switch to window that displays buffer bufNr
" 	return	0	all ok
" 			1	current window is target window 
" 			-1	buffer not displayed in any window
function! s:switchWindow(bufNr)
	let winNr = bufwinnr(a:bufNr)

	" buffer not displayed
	if winNr == -1
		return -1
	endif

	" switch to window winnr if not already in
	if winNr == winnr()
		return 1
	endif

	exe winNr . "wincmd w"
	return 0
endfunction

" toggle the scratch buffer
" 	if not exist				-> create
" 	if exist but not displayed	-> display
" 	if exist and displayed		-> switch to or close
function! s:scratchToggle()
	let scratchBufNr = bufnr(g:scratchBufName)

	" check whether scratch buffer is already created
	if scratchBufNr == -1
		let r = s:switchWindow(bufnr(g:TagList_title))

		if r == -1
			" taglist window not display
			" so open new scratch buffer
			exe "botright " . g:scratchWinWidth . "vsplit" . g:scratchBufName
		else
			" successfull switched
			" so open scratch in taglist window
			exe "below split" . g:scratchBufName
		endif

		setlocal buftype=nofile
		setlocal bufhidden=hide
		setlocal noswapfile
		setlocal buflisted

	else
		" switch to scratch buffer window
		let r = s:switchWindow(scratchBufNr)

		if r == 1
			" already in, so close window
			exe "quit"
		elseif r == -1
			" buffer not display, so open
			" first check taglist window (see above)
			let r = s:switchWindow(bufnr(g:TagList_title))

			if r == -1
				exe "botright " . g:scratchWinWidth . "vsplit +buffer" . scratchBufNr
			else
				exe "below split +buffer" . scratchBufNr
			endif
		endif
	endif
endfunction
