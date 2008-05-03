;;;; nix operating system project
;;;; list processor environment
;;;; Copyright (C) 2005-2008 Sven Klose <pixel@copei.de>

(defmacro with (alst &rest body)
  ; Make new WITH for rest of assignment list.
  (labels ((sub ()
             (if (cddr alst)
                 `((with ,(cddr alst) ,@body))
                 body)))

	; Get first pair.
    (let ((plc (first alst))
          (val (second alst)))

	  ; MULTIPLE-VALUE-BIND if place is a cons.
      (if (consp plc)
          `(multiple-value-bind ,plc ,val
			 ,@(sub))

		  ; Place function is set of value is a function.
		  (if (and (consp val) (eq (first val) 'FUNCTION))
			  `(labels ((,plc ,@(second val)))
				 ,@(sub))

			  ; Value assignment to variable.
          	  `(let ((,plc ,val))
				 ,@(sub)))))))
