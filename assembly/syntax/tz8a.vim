" Vim syntax file
" Language:	Telemark Z80 assembler 
" Maintainer:	David Hazel <dhazel@gmail.com>
" Last Change:	2007 August 20

" For version 5.x: Clear all syntax items
" For version 6.x: Quit when a syntax file was already loaded
if version < 600
  syntax clear
elseif exists("b:current_syntax")
  finish
endif

syn case ignore

" Common Z80 Assembly instructions
syn keyword z8aInstruction adc add and bit ccf cp cpd cpdr cpi cpir cpl
syn keyword z8aInstruction daa dec di djnz ei ex exx halt im in
syn keyword z8aInstruction inc ind ini indr inir ld ldd lddr ldi ldir
syn keyword z8aInstruction neg nop or otdr otir out outd outi
syn keyword z8aInstruction res rl rla rlc rlca rld
syn keyword z8aInstruction rr rra rrc rrca rrd sbc scf set sla sra
syn keyword z8aInstruction srl sub xor
" syn keyword z8aInstruction push pop call ret reti retn inc dec ex rst

" Any other stuff
syn match z8aIdentifier	"[a-zA-Z_][a-zA-Z0-9_]*"

" Instructions that change the stack (without conditionals)
syn keyword z8aInstruction push pop rst reti retn

" Instructions with conditionals
syn keyword z8aCondInst contained call ret jp jr
syn match z8aSpecInst1 "\(call\|jp\|jr\)\( \+\(c\|nc\|m\|p\|z\|nz\|pe\|po\),\| \+\)" contains=z8aConditional,z8aCondInst
syn match z8aSpecInst2 "\(ret\)\( \+\(c\|nc\|m\|p\|z\|nz\|pe\|po\)\| *$\| *;\+.*$\)" contains=z8aConditional,z8aCondInst,z8aComment

" Conditionals
syn keyword z8aConditional  contained c nc m p z nz pe po

" Labels
syn match z8aLabel	"^[a-zA-Z_][a-zA-Z0-9_\[\].~]*:*"

" PreProcessor commands
syn match z8aPreProc	"^\#\(include\|define\|defcont\|if\|ifdef\|ifndef\) "
syn match z8aPreProc	"^\#\(else\|endif\)"
syn match z8aPreProc	"=="
syn match z8aPreProc	"="
syn match z8aPreProc	"[-+]"
syn match z8aPreProc	"\(^\| \)\.org "
syn match z8aPreProc	"\(^\| \)\.db "
syn match z8aPreProc	"\(^\| \)\.dw "
syn match z8aPreProc	"\(^\| \)\.byte "
syn match z8aPreProc	"\(^\| \)\.word "
syn match z8aPreProc	"\(^\| \)\.module "
syn match z8aPreProc	"\(^\| \)\.sym "
syn match z8aPreProc	"\(^\| \)\.avsym "
syn match z8aPreProc	"\(^\| \)\.set "
syn match z8aPreProc	"\(^\| \)\.title "
syn match z8aPreProc	"\(^\| \)\.even "
syn match z8aPreProc	"\(^\| \)\.lsfirst "
syn match z8aPreProc	"\(^\| \)\.msfirst "
syn match z8aPreProc	"\(^\| \)\.locallabelchar "
syn match z8aPreProc	"\(^\| \)\.list "
syn match z8aPreProc	"\(^\| \)\.nolist "
syn match z8aPreProc	"\(^\| \)\.fill "
syn match z8aPreProc	"\(^\| \)\.export "
syn match z8aPreProc	"\(^\| \)\.equ "
syn match z8aPreProc	"\(^\| \)equ "
syn match z8aPreProc	"\(^\| \)\.page "
syn match z8aPreProc	"\(^\| \)\.eject "
syn match z8aPreProc	"\(^\| \)\.echo "
syn match z8aPreProc	"\(^\| \)\.chk "
syn match z8aPreProc	"\(^\| \)\.block "
syn match z8aPreProc	"\(^\| \)\.addinstr "
syn match z8aPreCondit	"\(^\| \)\.end "

" Common strings
syn match z8aString		"\".*\""
syn match z8aString		"\'.*\'"

" Various number formats
syn match hexNumber		"\$[0-9a-fA-F]\+\>"
syn match hexNumber		"\<[0-9][0-9a-fA-F]*H\>"
syn match octNumber		"@[0-7]\+\>"
syn match octNumber		"\<[0-7]\+[QO]\>"
syn match binNumber		"%[01]\+\>"
syn match binNumber		"\<[01]\+B\>"
syn match decNumber		"\<[0-9]\+D\=\>"

" Special items for comments
syn keyword z8aNote		contained NOTE
syn keyword z8aTodo		contained FIXME TODO

" Comments
syn match z8aComment		";.*" contains=z8aNote,z8aTodo

syn case match

" Define the default highlighting.
" For version 5.7 and earlier: only when not done already
" For version 5.8 and later: only when an item doesn't have highlighting yet
if version >= 508 || !exists("did_z8a_syntax_inits")
  if version < 508
    let did_z8a_syntax_inits = 1
    command -nargs=+ HiLink hi link <args>
  else
    command -nargs=+ HiLink hi def link <args>
  endif

  HiLink z8aSection		Special
  HiLink z8aLabel		Type
  HiLink z8aSpecialLabel	Type
  HiLink z8aComment		Comment
  HiLink z8aNote		Identifier
  HiLink z8aTodo                Todo
  HiLink z8aInstruction	        Statement
  HiLink z8aCondInst		Statement
  "HiLink z8aSpecInst		Statement
  HiLink z8aInclude		Include
  HiLink z8aPreCondit		PreCondit
  HiLink z8aPreProc		PreProc
  HiLink z8aNumber		Number
  HiLink z8aConditional         Identifier
  "HiLink z8aString		String

  HiLink hexNumber		Number		" Constant
  HiLink octNumber		Number		" Constant
  HiLink binNumber		Number		" Constant
  HiLink decNumber		Number		" Constant
 
  delcommand HiLink
endif

let b:current_syntax = "z8a"
" vim: ts=8
