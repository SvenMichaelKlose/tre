; tré – Copyright (c) 2008,2012–2013,2016 Sven Michael Klose <pixel@copei.de>

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

(defcsi ansi-set-color-raw (which c)
  (format t "~A~Am" which c))

;;;; Macros.

(defmacro define-ansi-cmd (cmd name args description &rest codes)
  `(defun ,name ,args
	 ,description
	 ,(. cmd codes)))

(defmacro ansi-defz (defname cmd)
  `(defmacro ,defname (name &rest args)
     `(define-ansi-cmd ,cmd ,,name () ,,@args)))

(ansi-defz ansi-defs ansi-set-flag)
(ansi-defz ansi-def-sgr ansi-sgr)
(ansi-defz ansi-def0 ansi-cmd0)

(defmacro ansi-def1 (&rest args)
  `(define-ansi-cmd ansi-cmd1 ,@args))

(defmacro ansi-def2 (&rest args)
  `(define-ansi-cmd ansi-cmd2 ,@args))

;;;; Public functions.

(defmacro ansi-defx (head cmds)
  `{,@(@ [. head _] cmds)})

(ansi-defx ansi-def0
	  ((ansi-reset          "Reset/restart terminal." #\m)
	   (ansi-cursor-save    "Save cursor state and position. One at a time." "s")
	   (ansi-cursor-restore "Restore cursor state and position." "u")
	   (ansi-home           "Move cursor to the top left corner." #\H)))

(ansi-defx ansi-def1
	  ((ansi-up (&optional (n 1))           "Move cursor up." n #\A)
	   (ansi-down (&optional (n 1))         "Move cursor down." n #\B)
	   (ansi-right (&optional (n 1))        "Move cursor right." n #\C)
	   (ansi-left (&optional (n 1))         "Move cursor left." n #\D)
	   (ansi-nextline (&optional (n 1))     "Move to next line." n #\E)
	   (ansi-prevline (&optional (n 1))     "Move to previous line." n #\F)
	   (ansi-column (n)                     "Move cursor to column N." (++ n) #\G)
	   (ansi-clrscr-after ()                "Clear screen after cursor." 0 #\J)
	   (ansi-clrscr-before ()               "Clear screen before cursor." 1 #\J)
	   (ansi-clrscr ()                      "Clear screen." 2 #\J)
	   (ansi-clrln-after ()                 "Clear line after cursor." 0 #\K)
	   (ansi-clrln-before ()                "Clear line before cursor." 1 #\K)
	   (ansi-clrln ()                       "Clear line." 2 #\K)
	   (ansi-scroll-up (&optional (n 1))    "Scroll screen up." n #\S)
	   (ansi-scroll-down (&optional (n 1))  "Scroll screen down." n #\T)
	   (ansi-sgr (x)                        "Print special graphics rendition control sequence." x #\m)))

(ansi-def2 ansi-position (x y) "Move cursor to absolute position." (++ y) (++ x) #\H)

(ansi-defs ansi-cursor-hide "Hide cursor." "25l")
(ansi-defs ansi-cursor-show "Show cursor." "25h")

(ansi-defx ansi-def-sgr
	  ((ansi-bold           "Print bold characters." "1")
	   (ansi-negative       "Print negative characters." "7")
	   (ansi-underline-on   "Print underlined characters." "21")
	   (ansi-normal         "Print normal characters." "22")))

(defvar *ansi-color-names* '(black red green yellow blue magenta cyan white))

(defun ansi-color (name &optional (high nil))
  "Translates symbol to ANSI color number."
  (+ (position name *ansi-color-names*)
     (? high
	    (length *ansi-color-names*)
	    0)))

(defmacro defcol (where high code)
  (with (name ($ 'ansi-
			     (? where 'foreground 'background)
			     '-color
			     (? high '-high "")
				 '-raw))
	 `(defun ,name (c)
        (ansi-set-color-raw ,code c))))

(defcol nil nil 4)
(defcol nil t 10)
(defcol t nil 3)
(defcol t t 9)

(defmacro defmastercol (where)
  (with (name ($ 'ansi- where '-color))
    `(defun ,name (code)
       (? (> code (length *ansi-color-names*))
	      (,($ name '-high-raw) (- code (length *ansi-color-names*)))
	      (,($ name '-raw) code)))))

(defmastercol foreground)
(defmastercol background)

(defun ansi-read-nonctrl ()
  (with (c (read-char))
	(? (> c 31)
	   c
	   (ansi-read-nonctrl))))

(defun ansi-read-natural-number (&optional (v 0))
  (with (c (read-char))
    (? (digit-char?  c)
	   (ansi-read-natural-number (+ (- c #\0) (* 10 v)))
	   v)))

(defun ansi-get-position ()
  "Get values of cursor position."
  (%terminal-raw)
  (ansi-cmd0 "6n")
  (force-output)
  (when (== #\[ (ansi-read-nonctrl))
     (with (height (ansi-read-natural-number)
     	    width  (ansi-read-natural-number))
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
  (ansi-foreground-color (ansi-color 'yellow t))
  (ansi-background-color (ansi-color 'black))
  (ansi-bold)
  (format t "ANSI terminal driver~%")
  (ansi-normal)
  (ansi-foreground-color (ansi-color 'white t)))
