;;;;; TRE environment
;;;;; Copyright (c) 2008 Sven Klose <pixel@copei.de>
;;;;;
;;;;; ANSI terminal functions.

(defun ansi-csi ()
  "Print control sequence initialiser."
  (princ (code-char 27))
  (princ #\[))

(defun ansi-cmd0 (x)
  "Print control sequence without arguments."
  (ansi-csi)
  (format t "~A" x))

(defun ansi-cmd1 (n c)
  "Print control sequence with argument."
  (ansi-csi)
  (format t "~A~A" n c))

(defun ansi-cmd2 (x y c)
  "Print control sequence with two arguments."
  (ansi-csi)
  (format t "~A;~A~A" x y c))

(defun ansi-set-flag (x)
  "Print control sequence for flag."
  (ansi-csi)
  (format t "?~A" x))

(defun ansi-up (&optional (n 1))
  "Move cursor up."
  (ansi-cmd1 n #\A))

(defun ansi-down (&optional (n 1))
  "Move cursor down."
  (ansi-cmd1 n #\B))

(defun ansi-right (&optional (n 1))
  "Move cursor right."
  (ansi-cmd1 n #\C))

(defun ansi-left (&optional (n 1))
  "Move cursor left."
  (ansi-cmd1 n #\D))

(defun ansi-nextline (&optional (n 1))
  (ansi-cmd1 n #\E))

(defun ansi-prevline (&optional (n 1))
  (ansi-cmd1 n #\F))

(defun ansi-column (n)
  "Move cursor to column N."
  (ansi-cmd1 (1+ n) #\G))

(defun ansi-home ()
  "Move cursor to the top left corner."
  (ansi-cmd0 #\H))

(defun ansi-position (x y)
  "Move cursor to absolute position."
  (ansi-cmd2 (1+ y) (1+ x) #\H))

(defun ansi-clrscr-after ()
  "Clear screen after cursor."
  (ansi-cmd1 0 #\J))

(defun ansi-clrscr-before ()
  "Clear screen before cursor."
  (ansi-cmd1 1 #\J))

(defun ansi-clrscr ()
  "Clear screen."
  (ansi-cmd1 2 #\J))

(defun ansi-clrln-after ()
  "Clear line after cursor."
  (ansi-cmd1 0 #\K))

(defun ansi-clrln-before ()
  "Clear line before cursor."
  (ansi-cmd1 1 #\K))

(defun ansi-clrln ()
  "Clear line."
  (ansi-cmd1 2 #\K))

(defun ansi-scroll-up (&optional (n 1))
  "Scroll screen up."
  (ansi-cmd1 n #\S))

(defun ansi-scroll-down (&optional (n 1))
  "Scroll screen down."
  (ansi-cmd1 n #\T))

(defun ansi-reset ()
  "Reset/restart terminal."
  (ansi-cmd0 #\m))

(defun ansi-sgr (x)
  "Print special graphics redition control sequence."
  (ansi-cmd1 x #\m))

(defun ansi-cursor-hide ()
  "Hide cursor."
  (ansi-set-flag "25l"))

(defun ansi-cursor-show ()
  "Show cursor."
  (ansi-set-flag "25h"))

(defun ansi-cursor-save ()
  "Save cursor state and position. One at a time."
  (ansi-cmd0 "s"))

(defun ansi-cursor-restore ()
  "Restore cursor state and position."
  (ansi-cmd0 "u"))

(defun ansi-bold ()
  "Print bold characters."
  (ansi-sgr "1"))

(defun ansi-negative ()
  "Print negative characters."
  (ansi-sgr "7"))

(defun ansi-underline-on ()
  "Print underlined characters."
  (ansi-sgr "21"))

(defun ansi-normal ()
  "Print normal characters."
  (ansi-sgr "22"))

(defun ansi-set-color (which c)
  (ansi-csi)
  (format t "~A~Am" which c))

(defun ansi-foreground-color (c)
  (ansi-set-color 3 c))

(defun ansi-background-color (c)
  (ansi-set-color 4 c))

(defun ansi-foreground-color-high (c)
  (ansi-set-color 9 c))

(defun ansi-background-color-high (c)
  (ansi-set-color 10 c))

(defun ansi-color (name)
  "Translates symbol to ANSI color number."
  (position name '(black red green yellow blue magenta cyan white)))

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
