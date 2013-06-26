;;; tré – Copyright (c) 2013 Sven Michael Klose <pixel@copei.de>
;;;
;;; BASIC program to call machine code at $80d.

* = $7ff

load_address:
    .word $801

    .word basic_end
    .word 1     ; Line number
    .byte $9e   ; SYS token
    .asc "2061"
    .byte 0
basic_end:
    .word 0
