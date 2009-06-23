;;;;; Transpiler: TRE to JavaScript
;;;;; Copyright (c) 2008-2009 Sven Klose <pixel@copei.de>
;;;;;
;;;;; Toplevel

(defvar *nil-symbol-name* nil)

(defun transpiler-print-obfuscations (tr)
  (dolist (k (hashkeys (transpiler-obfuscations tr)))
    (unless (in=? (elt (symbol-name k) 0) #\~) ; #\_)
	  (format t "~A -> ~A~%" (symbol-name k)
						     (href (transpiler-obfuscations tr) k)))))

(defun js-transpile-0 (f files)
  (format f "var _I_ = 0; while (1) {switch (_I_) {case 0: ~%")
  (format f "var ~A;~%" (transpiler-symbol-string
							*js-transpiler*
							 (transpiler-obfuscate-symbol
								 *js-transpiler*
								 '*CURRENT-FUNCTION*)))
  (when (transpiler-lambda-export? *js-transpiler*)
	(transpiler-add-wanted-function *js-transpiler* 'array-copy)
	(princ ,(concat-stringtree
			    (with-open-file i (open "transpiler/javascript/funref.js"
							 			:direction 'input)
			  	  (read-all-lines i)))
		   f))
  (with (tr *js-transpiler*
		 ; Expand.
		 base (transpiler-sighten tr *js-base*)
    	 base2 (transpiler-sighten tr *js-base2*)
		 tests (when (eq t *have-environment-tests*)
				 (transpiler-sighten tr (make-environment-tests)))
	 	 user (transpiler-sighten-files tr files)
		 deps (progn
				(format t "; Collecting dependencies...~%")
				(transpiler-import-from-environment tr)))
	; Generate.
	(format t "; Let me think. Hmm")
	(force-output)
    (princ (concat-stringtree
 		     (transpiler-transpile tr base)
		     (transpiler-transpile tr deps)
 		     (transpiler-transpile tr base2)
			 (transpiler-transpile tr tests)
 		     (transpiler-transpile tr user))
	       f))
  (format f "}break;}~%")
  (format t "~%; Everything OK. ~A instructions. Done.~%"
			*codegen-num-instructions*)
  (transpiler-print-obfuscations *js-transpiler*))

(defun js-transpile (out files &key (obfuscate? nil))
  (setf *current-transpiler* *js-transpiler*)
  (transpiler-reset *js-transpiler*)
  (transpiler-switch-obfuscator *js-transpiler* obfuscate?)
  (setf *nil-symbol-name*
		(symbol-name (transpiler-obfuscate-symbol-0 *js-transpiler* nil)))
  (js-transpile-0 out files))
