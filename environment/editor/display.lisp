;;;;; TRE environment - editor
;;;;; Copyright (c) 2008 Sven Klose <pixel@copei.de>
;;;;;
;;;;; Displaying stuff.

(defun editor-default-color (ed)
  "Set default text color."
  (ansi-background-color (editor-conf 'color-text-background))
  (ansi-foreground-color (editor-conf 'color-text-foreground)))

(defun editor-scroll-up (ed n)
  (ansi-scroll-down n)
  (decf (editor-state-line-offset ed) n)
  (dotimes (y n)
	(editor-redraw-line y)))

(defun editor-scroll-down (ed n)
  (ansi-scroll-up n)
  (incf (editor-state-line-offset ed) n)
  (dotimes (y n)
    (editor-redraw-line ed (- (terminal-height (editor-state-terminal ed)) 2 y))))

(defun editor-scroll-left (ed n)
  (decf (editor-state-column-offset ed) n)
  (editor-redraw ed))

(defun editor-scroll-right (ed n)
  (incf (editor-state-column-offset ed) n)
  (editor-redraw ed))

(defun editor-clear-bottom (ed)
  (editor-default-color ed)
  (ansi-position 0 (1-(terminal-height (editor-state-terminal ed))))
  (ansi-clrln))

(defun editor-expand-line (ed line &optional (i 0) (pos 0))
  (with (expand-tab
		  #'((line i pos)
  		       (if (= 0 (mod pos (editor-conf 'tabstop)))
      		       (editor-expand-line ed line (1+ i) pos)
      		       (cons 32 (expand-tab line i (1+ pos))))))
    (when (< i (length line))
      (with (c (elt line i))
        (if (= c 9)
		    (cons 32 (expand-tab line i (1+ pos)))
            (cons c (editor-expand-line ed line (1+ i) (1+ pos))))))))

(defun editor-home (ed)
  (editor-clear-bottom ed)
  (with (x	(editor-state-x ed)
  		 y	(editor-state-y ed)
		 terminal (editor-state-terminal ed)
		 text (editor-state-text ed))
	(ansi-bold)
	(ansi-foreground-color (ansi-color 'white t))
	(when (editor-state-mode ed)
	  (ansi-column 0)
	  (princ (editor-state-mode ed)))

  	(ansi-position (integer (/ (terminal-width terminal) 2)) (1- (terminal-height terminal)))

	(ansi-foreground-color (ansi-color 'white t))
    (princ #\")
	(ansi-foreground-color (ansi-color 'blue t))
	(princ (editor-state-name ed))
	(ansi-foreground-color (ansi-color 'white t))
    (princ #\")

    (princ #\ )

    (princ (+ 1 x (editor-state-column-offset ed)))
    (princ #\:)
    (princ (+ 1 y (editor-state-line-offset ed)))
    (princ #\/)
    (princ (length (text-container-lines text)))

    (princ #\ )
    (princ (editor-state-line-offset ed))

	(ansi-normal)
    (ansi-position x y)))

(defun editor-draw-invalid-line (ed)
  (ansi-foreground-color (ansi-color 'blue t))
  (ansi-bold)
  (princ #\~)
  (ansi-normal)
  (ansi-clrln-after))

(defun editor-draw-line (ed y)
  (editor-default-color ed)
  (with (line (list-string (editor-expand-line ed
								(elt (text-container-lines (editor-state-text ed)) y))))
    (dotimes (x (terminal-width (editor-state-terminal ed)))
      (with (xl (+ x (editor-state-column-offset ed)))
	    (when (>= xl (length line))
		  (return-from editor-draw-line nil))
	    (princ (elt line xl))))))

(defun editor-redraw-line (ed &optional (n nil))
  (with (y (or n (editor-state-y ed)))
    (ansi-position 0 y)
    (ansi-clrln)
    (with (ty (+ y (editor-state-line-offset ed)))
      (if (>= ty (length (text-container-lines (editor-state-text ed))))
          (editor-draw-invalid-line ed)
          (editor-draw-line ed ty)))))

(defun editor-redraw (ed)
  (ansi-home)
  (ansi-normal)
  (dotimes (y (1- (terminal-height (editor-state-terminal ed))))
	(editor-redraw-line ed y))
  (editor-home ed))
