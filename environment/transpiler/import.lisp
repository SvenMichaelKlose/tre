;;;;; TRE transpiler
;;;;; Copyright (c) 2008-2009 Sven Klose <pixel@copei.de>
;;;;;
;;;;; Import functions and variable from the environment.

(defun transpiler-defined? (tr name)
  (or (transpiler-defined-function tr name)
  	  (transpiler-defined-variable tr name)
  	  (transpiler-wanted-function? tr name)
  	  (transpiler-wanted-variable? tr name)
	  (transpiler-unwanted-function? tr name)
	  (transpiler-macro tr name)))

(defun transpiler-can-import? (tr name)
  (and (transpiler-import-from-environment? tr)
 	   (symbolp name)
  	   (not (transpiler-defined? tr name))))
	
(defun starts-with (x head)
  (let s (force-string x)
    (string= head (subseq s 0 (length head)))))

(defun transpiler-add-wanted-function (tr x)
  (unless (and (symbolp x)
			   (not (builtinp x))
			   (or (starts-with x "ALIEN-")
			   	   (starts-with x "UNIX")
			   	   (starts-with x "LEXICAL-TEST")
			   	   (starts-with x "C-CALL")
			   	   (starts-with x "EXEC")
			   	   (starts-with x "WAIT")
;			   	   (starts-with x "CONVERT-SPECIAL")
			   	   (starts-with x "XML2LML")
			   	   (starts-with x "XML")
			   	   (starts-with x "FORK")
			   	   (starts-with x "GET-DEFINER")
				   (eq 'random x)
				   (eq 'rec x))
			  (not (in? x 'XML-ENTITIES-TO-UNICODE-0
						  'XML-ENTITIES-TO-UNICODE)))
    (when (transpiler-can-import? tr x)
	  (setf (href (transpiler-wanted-functions-hash tr) x) t)
	  (nconc! (transpiler-wanted-functions tr)
			  (list x))))
    x)

(defun transpiler-should-add-wanted-variable? (tr var)
  (and (transpiler-can-import? tr var)
	   (assoc var *variables* :test #'eq)))

(defun transpiler-add-wanted-variable (tr var)
  (when (atom var)
    (when (and (transpiler-should-add-wanted-variable? tr var)
			   (not (href (transpiler-wanted-variables-hash tr) var)))
	  (setf (href (transpiler-wanted-variables-hash tr) var) t)
      (nconc! (transpiler-wanted-variables tr)
			  (list var))))
  var)

(defun transpiler-import-exported-closures (tr)
  (when *lambda-exported-closures*
	(append (transpiler-sighten tr (pop *lambda-exported-closures*))
		    (transpiler-import-exported-closures tr))))

(defvar *imported-something* nil)
(defvar *delayed-var-inits* nil)

(defun transpiler-import-wanted-function (tr x)
  (append 
      (transpiler-import-exported-closures tr)
      (unless (transpiler-defined-function tr x)
        (transpiler-add-emitted-wanted-function tr x)
        (let fun (symbol-function x)
          (when (functionp fun)
		    (setf *imported-something* t)
            (transpiler-sighten tr
      	        `((defun ,x ,(function-arguments fun)
	                ,@(function-body fun)))))))))

(defun transpiler-import-wanted-functions (tr)
  (append
      (mapcan (fn transpiler-import-wanted-function tr _)
    	      (transpiler-wanted-functions tr))
      (transpiler-import-exported-closures tr)))

(defun transpiler-import-wanted-variables (tr)
  (transpiler-sighten tr
    (mapcar (fn (unless (transpiler-defined-variable tr _)
				  (setf *imported-something* t)
				  (setf *delayed-var-inits*
						(append (transpiler-sighten tr
								    `((setf ,_ ,(assoc-value _ *variables*
															 :test #'eq))))
 							    *delayed-var-inits*))
				  `(defvar ,_ nil)))
		    (transpiler-wanted-variables tr))))

(defun transpiler-import-from-environment (tr)
  (clr *imported-something*)
  (with (funs (transpiler-import-wanted-functions tr)
		 vars (transpiler-import-wanted-variables tr))
	(if *imported-something*
	    (append funs vars (transpiler-import-from-environment tr))
	    *delayed-var-inits*)))

(defun transpiler-import-from-expex (x)
  (aif (atom-function-expr? x)
       (progn
         (unless (funinfo-in-this-or-parent-env? *expex-funinfo* !)
           (transpiler-add-wanted-function *current-transpiler* !))
         `(symbol-function (%quote ,!)))
       (aif (vec-function-expr? x)
           !
           x)))

(defun transpiler-import-universe (tr)
  (dolist (i (reverse *defined-functions*))
	(when (and (symbolp i)
			   (not (builtinp i))
			   (symbol-function i))
	  (transpiler-add-wanted-function tr i))))
