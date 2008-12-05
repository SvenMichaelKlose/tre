;;;;; TRE to C transpiler
;;;;; Copyright (c) 2008 Sven Klose <pixel@copei.de>
;;;;;
;;;;; Toplevel

(defun c-transpile (outfile infiles)
  (with (;base (or (format t "Compiling C core...~%")
   			;	  (transpiler-expand-and-generate-code *c-transpiler* *c-base*))
		 x nil)
	(dolist (file infiles)
	  (format t "Compiling '~A'...~%" file)
  	  (with-open-file f (open file :direction 'input)
        ;(with-open-file o (open (string-concat file ".obj") :direction 'output)
	      (with (vcode (transpiler-sight *c-transpiler* (read-many f)))
			;(newprint vcode o)
	        (setf x (append x vcode)))));)
    (with-open-file f (open outfile :direction 'output)
	    (with (user (transpiler-transpile *c-transpiler* x))
	      (format t "Emitting code to '~A'...~%" outfile)
		  (format f "~A" ;~A" base
						   user)))))

;; XXX defunct
(defun c-machine (outfile)
  (with-open-file f (open outfile :direction 'output)
    (format f "~A"
			(transpiler-concat-string-tree
			  (transpiler-collect-wanted
				*c-transpiler*
				#'transpiler-expand-and-generate-code
				(reverse *UNIVERSE*))))))
