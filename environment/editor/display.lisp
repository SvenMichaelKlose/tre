;;;;; TRE environment - editor
;;;;; Copyright (c) 2008 Sven Klose <pixel@copei.de>
;;;;;
;;;;; Displaying stuff.

(defun editor-default-color ()
  "Set default text color."
  (ansi-background-color (editor-conf 'color-text-background))
  (ansi-foreground-color (editor-conf 'color-text-foreground)))

(defun editor-scroll-up (n)
  (ansi-scroll-down n)
  (decf (editor-state-line-offset *editor-state*) n)
  (dotimes (y n)
	(editor-redraw-line y)))

(defun editor-scroll-down (n)
  (ansi-scroll-up n)
  (incf (editor-state-line-offset *editor-state*) n)
  (dotimes (y n)
    (editor-redraw-line (- (terminal-height *terminal*) 2 y))))

(defun editor-scroll-left (n)
  (decf (editor-state-column-offset *editor-state*) n)
  (editor-redraw))

(defun editor-scroll-right (n)
  (incf (editor-state-column-offset *editor-state*) n)
  (editor-redraw))

(defun editor-clear-bottom ()
  (editor-default-color)
  (ansi-position 0 (1-(terminal-height *terminal*)))
  (ansi-clrln))

(defun editor-expand-line (line &optional (i 0) (pos 0))
  (with (expand-tab
		  #'((line i pos)
  		       (if (= 0 (mod pos (editor-conf 'tabstop)))
      		       (editor-expand-line line (1+ i) pos)
      		       (cons 32 (expand-tab line i (1+ pos))))))
    (when (< i (length line))
      (with (c (elt line i))
        (if (= c 9)
		    (cons 32 (expand-tab line i (1+ pos)))
            (cons c (editor-expand-line line (1+ i) (1+ pos))))))))

(defun editor-home ()
  (editor-clear-bottom)
  (with (x	(editor-state-x *editor-state*)
  		 y	(editor-state-y *editor-state*))
	(ansi-bold)
	(ansi-foreground-color (ansi-color 'white t))
	(when (editor-state-mode *editor-state*)
	  (ansi-column 0)
	  (princ (editor-state-mode *editor-state*)))

  	(ansi-position (integer (/ (terminal-width *terminal*) 2)) (1- (terminal-height *terminal*)))

	(ansi-foreground-color (ansi-color 'white t))
    (princ #\")
	(ansi-foreground-color (ansi-color 'blue t))
	(princ (editor-state-name *editor-state*))
	(ansi-foreground-color (ansi-color 'white t))
    (princ #\")

    (princ #\ )

    (princ (+ 1 x (editor-state-column-offset *editor-state*)))
    (princ #\:)
    (princ (+ 1 y (editor-state-line-offset *editor-state*)))
    (princ #\/)
    (princ (length (text-container-lines *text*)))

    (princ #\ )
    (princ (editor-state-line-offset *editor-state*))

	(ansi-normal)
    (ansi-position x y)))

(defun editor-draw-invalid-line ()
  (ansi-foreground-color (ansi-color 'blue t))
  (ansi-bold)
  (princ #\~)
  (ansi-normal)
  (ansi-clrln-after))

(defun editor-draw-line (y)
  (editor-default-color)
  (with (line (list-string (editor-expand-line (elt (text-container-lines *text*) y))))
    (dotimes (x (terminal-width *terminal*))
      (with (lx (+ x (editor-state-column-offset *editor-state*)))
	    (when (>= lx (length line))
		  (return-from editor-draw-line nil))
	    (princ (elt line lx))))))

(defun editor-redraw-line (&optional (n nil))
  (with (y	(or n (editor-state-y *editor-state*)))
    (ansi-position 0 y)
    (ansi-clrln)
    (with (ty (+ y (editor-state-line-offset *editor-state*)))
      (if (> ty (length (text-container-lines *text*)))
          (editor-draw-invalid-line)
          (editor-draw-line ty)))))

(defun editor-redraw ()
  (ansi-home)
  (ansi-normal)
  (dotimes (y (1- (terminal-height *terminal*)))
	(editor-redraw-line y))
  (editor-home))
