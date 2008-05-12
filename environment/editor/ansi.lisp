;;;;; TRE environment
;;;;; Copyright (c) 2008 Sven Klose <pixel@copei.de>
;;;;;
;;;;; ANSI terminal functions.

;;;; Primitives.

(defun ansi-csi ()
  "Print control sequence initialiser."
  (princ (code-char 27))
  (princ #\[))

(define-template-macro defcsi
  ((ansi-csi)))

(defcsi ansi-cmd0 (x)
  "Print control sequence without arguments."
  (format t "~A" x))

(defcsi ansi-cmd1 (n c)
  "Print control sequence with argument."
  (format t "~A~A" n c))

(defcsi ansi-cmd2 (x y c)
  "Print control sequence with two arguments."
  (format t "~A;~A~A" x y c))

(defcsi ansi-set-flag (x)
  "Print control sequence for flag."
  (format t "?~A" x))

(defcsi ansi-set-color (which c)
  (format t "~A~Am" which c))

;;;; Macros.

(defmacro defc (cmd name args description &rest codes)
  `(defun ,name ,args
	 ,description
	 ,(cons cmd codes)))

(defmacro %defz (defname cmd)
  `(defmacro ,defname (name &rest args)
     `(defc ,cmd ,,name () ,,@args)))

(%defz defs ansi-set-flag)
(%defz def-sgr ansi-sgr)
(%defz def0 ansi-cmd0)

(defmacro def1 (&rest args)
  `(defc ansi-cmd1 ,@args))

(defmacro def2 (&rest args)
  `(defc ansi-cmd2 ,@args))

;;;; Public functions.

(defmacro defx (head cmds)
  (cons 'progn
	 	(mapcar #'((x) (cons head x)) cmds)))

(defx def0
	  ((ansi-reset "Reset/restart terminal." #\m)
	   (ansi-cursor-save "Save cursor state and position. One at a time." "s")
	   (ansi-cursor-restore "Restore cursor state and position." "u")
	   (ansi-home "Move cursor to the top left corner." #\H)))

(defx def1
	  ((ansi-up (&optional (n 1)) "Move cursor up." n #\A)
	   (ansi-down (&optional (n 1)) "Move cursor down." n #\B)
	   (ansi-right (&optional (n 1)) "Move cursor right." n #\C)
	   (ansi-left (&optional (n 1)) "Move cursor left." n #\D)
	   (ansi-nextline (&optional (n 1)) "Move to next line." n #\E)
	   (ansi-prevline (&optional (n 1)) "Move to previous line." n #\F)
	   (ansi-column (n) "Move cursor to column N." (1+ n) #\G)
	   (ansi-clrscr-after () "Clear screen after cursor." 0 #\J)
	   (ansi-clrscr-before () "Clear screen before cursor." 1 #\J)
	   (ansi-clrscr () "Clear screen." 2 #\J)
	   (ansi-clrln-after () "Clear line after cursor." 0 #\K)
	   (ansi-clrln-before () "Clear line before cursor." 1 #\K)
	   (ansi-clrln () "Clear line." 2 #\K)
	   (ansi-scroll-up (&optional (n 1)) "Scroll screen up." n #\S)
	   (ansi-scroll-down (&optional (n 1)) "Scroll screen down." n #\T)
	   (ansi-sgr (x) "Print special graphics redition control sequence." x #\m)))

(def2 ansi-position (x y) "Move cursor to absolute position." (1+ y) (1+ x) #\H)

(defs ansi-cursor-hide "Hide cursor." "25l")
(defs ansi-cursor-show "Show cursor." "25h")

(defx def-sgr
	  ((ansi-bold "Print bold characters." "1")
	   (ansi-negative "Print negative characters." "7")
	   (ansi-underline-on "Print underlined characters." "21")
	   (ansi-normal "Print normal characters." "22")))

(defun ansi-color (name)
  "Translates symbol to ANSI color number."
  (position name '(black red green yellow blue magenta cyan white)))

(defmacro defcol (where high code)
  (with (name ($ 'ansi-
			     (if where 'foreground 'background)
			     '-color
			     (if high '-high "")))
	 `(defun ,name (c)
        (ansi-set-color ,code c))))

(defcol nil nil 4)
(defcol nil t 10)
(defcol t nil 3)
(defcol t t 9)

(defun ansi-read-nonctrl ()
  (with (c (read-char))
	(if (> c 31)
		c
		(ansi-read-nonctrl))))

(defun ansi-read-digit (&optional (v 0))
  (with (c (read-char))
    (if (digit-char-p  c)
	    (ansi-read-digit (+ (- c #\0) (* 10 v)))
		v)))

(defun ansi-get-position ()
  "Get values of cursor position."
  (%terminal-raw)
  (ansi-cmd0 "6n")
  (force-output)
  (when (= #\[ (ansi-read-nonctrl))
     (with (height (ansi-read-digit)
     	    width  (ansi-read-digit))
  	   (%terminal-normal)
	   (values width height))))

(defun ansi-dimensions ()
  "Get values of screen dimensions."
  (with ((x y) (ansi-get-position))
    (dotimes (n 8)
      (ansi-down 255)
      (ansi-right 255))
    (prog1
	  (ansi-get-position)
	  (ansi-position x y))))

(defun ansi-welcome ()
  (ansi-foreground-color-high (ansi-color 'yellow))
  (ansi-background-color (ansi-color 'black))
  (ansi-bold)
  (format t "ANSI terminal driver~%")
  (ansi-normal)
  (ansi-foreground-color-high (ansi-color 'white)))

(ansi-welcome)
