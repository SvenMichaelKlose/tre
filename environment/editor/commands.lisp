;;;;; TRE environment - editor
;;;;; Copyright (c) 2008 Sven Klose <pixel@copei.de>
;;;;;
;;;;; Commands.

(defun editor-expand-pos (line p &optional (i 0) (pos 0))
  (with (expand-tab
		  #'((line p i pos)
  			   (if (= p i)
	  			   pos
      			   (if (= 0 (mod pos (editor-conf 'tabstop)))
          			   (editor-expand-pos line p (1+ i) pos)
          			   (expand-tab line p i (1+ pos))))))
    (if (= p i)
	    pos
        (if (< i (length line))
          (with (c (elt line i))
            (if (= c 9)
		        (expand-tab line p i (1+ pos))
                (editor-expand-pos line p (1+ i) (1+ pos))))
	      pos))))

(defun editor-cmd-quit (ed)
  (setf (editor-state-quit? ed) t))

(defun editor-cmd-write (ed)
  (editor-write (editor-state-name ed)
				(editor-state-text ed)))

(defun editor-cmd-up (ed &optional (nn 1))
  (with (y (editor-state-y ed)
    	 n (text-container-up (editor-state-text ed) nn))
    (desaturate! (editor-state-y ed) y n)
    (when (< y n)
      (editor-scroll-up ed (- n y)))))

(defun editor-cmd-left (ed &optional (nn 1))
  (let text (editor-state-text ed)
    (text-container-left text nn)
    (with (x (editor-state-x ed)
		   nx (editor-expand-pos (text-container-line text) (text-container-x text))
		   n (- x nx))
      (desaturate! (editor-state-x ed) x n)
      (when (< x n)
        (editor-scroll-left ed (- n x))))))

(defun editor-cmd-down (ed &optional (nn 1))
  (with (y		(editor-state-y ed)
         th		(1- (terminal-height (editor-state-terminal ed)))
  		 text	(editor-state-text ed)
		 n		(text-container-down text nn))
    (saturate! (editor-state-y ed) y n th)
    (when (saturates? y n th)
	  (with (s	(- n (- th y)))
		(if (>= s th)
			(editor-redraw ed)
            (editor-scroll-down ed s))))))

(defun editor-cmd-right (ed &optional (nn 1))
  (let text (editor-state-text ed)
    (text-container-right text nn)
    (with (x		(editor-state-x ed)
		   nx		(editor-expand-pos (text-container-line text) (text-container-x text))
           tw		(terminal-width (editor-state-terminal ed))
		   n		(- nx x))
	  (saturate! (editor-state-x ed) x n tw)
      (when (saturates? x n tw)
        (editor-scroll-right ed (- n (- tw x)))))))

(defun editor-cmd-line-start (ed)
  (with (a (editor-state-column-offset ed))
    (setf (editor-state-column-offset ed) 0
		  (editor-state-x ed) 0
		  (text-container-x (editor-state-text ed)) 0)
	(when a
	  (editor-redraw ed))))

(defun editor-cmd-last-line (ed)
  (editor-cmd-down ed (length (text-container-lines (editor-state-text ed)))))

(defun editor-insert-char (ed c)
  (text-container-insert-char (editor-state-text ed) c)
  (editor-cmd-right ed))

(define-tail-macro rcmd
  ((editor-redraw-line ed)))

(rcmd editor-delete-char (ed)
  (editor-cmd-left ed)
  (text-container-delete-char (editor-state-text ed)))

(rcmd editor-cmd-insert-char (ed c)
  (editor-insert-char ed c))

(rcmd editor-cmd-delete-char (ed)
  (setf (editor-state-mode ed) "DELETE")
  (editor-delete-char ed))

(defun editor-input-char (ed)
  (editor-home ed)
  (with (c (read-char))
	(unless (= c 27)
	  (case (integer c)
	    (8		(editor-cmd-left ed))
	    (10		(editor-cmd-down ed))
	    (11		(editor-cmd-up ed))
	    (12		(editor-cmd-right ed))
	    (127	(editor-cmd-delete-char ed))
	    (t		(editor-cmd-insert-char ed c)))
	  (editor-input-char ed))))

(defun editor-cmd-input (ed)
  (setf (editor-state-mode ed) "INSERT")
  (editor-input-char ed)
  (setf (editor-state-mode ed) nil))

;(defun editor-cmd-para (ed direction)
;  `(defun ,($ "editor-cmd-para-" direction) ()
;     (,($ "editor-cmd-" direction))
;     (when (text-container-line (editor-state-text ed))
;       (self))))
;
;(editor-cmd-para up)
;(editor-cmd-para down)

(defun editor-cmd-help (ed)
  (ansi-clrscr)
  (ansi-home)
  (ansi-bold)
  (ansi-foreground-color (ansi-color 'cyan t))
  (format t "TRE built-in editor help page~%")
  (format t "~%")
  (ansi-normal)
  (ansi-foreground-color (ansi-color 'cyan))
  (format t "  Toplevel controls~%")
  (format t "~%")
  (ansi-foreground-color (ansi-color 'white t))
  (format t "  h   left~%")
  (format t "  l   right~%")
  (format t "  k   up~%")
  (format t "  j   down~%")
  (format t "~%")
  (format t "  0   line start~%")
  (format t "  G   last line~%")
  (format t "~%")
  (format t "  i   enter insert mode~%")
  (format t "~%")
  (format t "  :w  write file~%")
  (format t "  :q  leave editor~%")
  (format t "~%")
  (ansi-foreground-color (ansi-color 'cyan))
  (format t "  Insert mode controls~%")
  (format t "~%")
  (ansi-foreground-color (ansi-color 'white t))
  (format t "  ESC      leave insert mode~%")
  (format t "  CTRL+h   left~%")
  (format t "  CTRL+l   right~%")
  (format t "  CTRL+k   up~%")
  (format t "  CTRL+j   down~%")
  (format t "~%")
  (ansi-bold)
  (format t "Press a key...~%")
  (read-char)
  (editor-redraw ed))

(defun editor-cmd-2 (ed)
  (editor-clear-bottom ed)
  (princ #\:)
  (let c (read-char)
    (when (> c 31)
	  (princ c))
    (case c
	  (#\q	(editor-cmd-quit ed))
	  (#\w	(editor-cmd-write ed))))
  (editor-clear-bottom ed)
  (editor-home ed))

(defun editor-cmd (ed)
  (case (read-char)
	(#\j	(editor-cmd-down ed))
	(#\k	(editor-cmd-up ed))
	(#\h	(editor-cmd-left ed))
	(#\l	(editor-cmd-right ed))
	(#\i	(editor-cmd-input ed))
	(#\0	(editor-cmd-line-start ed))
	(#\G	(editor-cmd-last-line ed))
	(#\H	(editor-cmd-help ed))
	(#\:	(editor-cmd-2 ed)))
  (editor-home ed))
