;;;; nix operating system project
;;;; list processor environment
;;;; Copyright (C) 2005-2008 Sven Klose <pixel@copei.de>

(defmacro with (alst &rest body)
  (labels ((sub ()
             (if (cddr alst)
                 `((with ,(cddr alst) ,@body))
                 body)))
    (let ((plc (car alst))
          (val (cadr alst)))
      (if (consp plc)
          `(multiple-value-bind ,plc ,val
			 ,@(sub))
		  (if (and (consp val) (eq (car val) 'FUNCTION))
			  `(labels ((,plc ,(second val)))
				 ,@(sub))
          	  `(let ((,plc ,val))
				 ,@(sub)))))))
