;;;;; Transpiler: TRE to PHP
;;;;; Copyright (c) 2008-2009 Sven Klose <pixel@copei.de>
;;;;;
;;;;; Toplevel

(defvar *nil-symbol-name* nil)

(defun php-gen-funref-wrapper (out)
  (princ ,(concat-stringtree
		      (with-open-file i (open "environment/transpiler/targets/php/funref.php"
							 		  :direction 'input)
			  	(read-all-lines i)))
		 out))

(defun php-transpile-prepare (tr out &key (import-universe? nil))
  (when import-universe?
    (transpiler-import-universe tr))
  (transpiler-add-wanted-function tr 'array-copy)
  (format out "<?php~%$NULL=NULL;~%$t=True;~%")
  (format out "function & __w ($x) { return $x; }~%")
  (php-gen-funref-wrapper out))

(defun php-transpile-0 (f files &key (base? nil))
  (with (tr *php-transpiler*
    	 base  (transpiler-sighten tr *php-base*)
    	 base2 (transpiler-sighten tr *php-base2*)
;		 base-debug (when *transpiler-assert*
;				      (transpiler-sighten tr *php-base-debug-print*))
		 tests (when (eq t *have-environment-tests*)
				 (transpiler-sighten tr (make-environment-tests)))
	 	 user (transpiler-sighten-files tr files)
		 deps (progn
				(format t "; Collecting dependencies...~%")
				(transpiler-import-from-environment tr))
		 inits (transpiler-sighten tr (transpiler-compiled-inits tr)))
	; Generate.
    (format t "; Let me think. Hmm")
    (princ (concat-stringtree
 	           (transpiler-transpile tr inits)
			   (when base?
 	             (transpiler-transpile tr base))
			   (when base?
 	             (transpiler-transpile tr base2))
 	           (transpiler-transpile tr deps)
;			   (when (and base? *transpiler-assert*)
; 		         (transpiler-transpile tr base-debug))
 	           (transpiler-transpile tr tests)
 	           (transpiler-transpile tr user))
	       f)
	(princ "?>" f)
    (transpiler-print-obfuscations tr)))

(defun php-transpile-ok ()
  (format t "~%; Everything OK. ~A instructions. Done.~%"
			*codegen-num-instructions*))

(defun php-transpile (out files &key (obfuscate? nil) (env? nil))
  (let tr *php-transpiler*
    (setf *current-transpiler* tr)
    (transpiler-reset tr)
    (transpiler-switch-obfuscator tr obfuscate?)
	(make-global-funinfo)
    (setf *nil-symbol-name*
		  (symbol-name (transpiler-obfuscate-symbol-0 tr nil)))
    (php-transpile-prepare tr out :import-universe? nil)
    (php-transpile-0 out files :base? t)
	(php-transpile-ok)))
