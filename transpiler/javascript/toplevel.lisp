;;;;; Transpiler: TRE to JavaScript
;;;;; Copyright (c) 2008 Sven Klose <pixel@copei.de>
;;;;;
;;;;; Toplevel

(defun js-transpile (outfile infiles)
  (with (base (or (format t "Compiling JavaScript core...~%")
   				  (transpiler-expand-and-generate-code *js-transpiler* *js-base*))
		 x nil
		 wanted-functions nil)
	(dolist (file infiles)
	  (format t "Compiling '~A'...~%" file)
  	  (with-open-file f (open file :direction 'input)
;        (with-open-file o (open (string-concat file ".obj") :direction 'output)
	      (with (wf (transpiler-wanted-functions *js-transpiler*)
	      		 vcode (transpiler-sight *Js-transpiler* (read-many f)))
;			(newprint wf o)
;			(setf wanted-functions (append wanted-functions wf))
;			(newprint vcode o)
	        (setf x (append x vcode)))));)
;	(setf (transpiler-wanted-functions *js-transpiler*) wanted-functions)

    (with-open-file f (open outfile :direction 'output)
	    (with (user (transpiler-transpile *js-transpiler* x))
	      (format t "Emitting code to '~A'...~%" outfile)
		  (format f "~A~A" base user)))))

;; XXX defunct
(defun js-machine (outfile)
  (with-open-file f (open outfile :direction 'output)
    (format f "~A"
			(transpiler-concat-strings
			  (transpiler-wanted *js-transpiler* #'transpiler-expand-and-generate-code (reverse *UNIVERSE*))))))
