;;;;; Transpiler: TRE to JavaScript
;;;;; Copyright (c) 2008-2010 Sven Klose <pixel@copei.de>
;;;;;
;;;;; Toplevel

(defvar *nil-symbol-name* nil)

(defun js-transpile-print-prologue (out tr)
  (format out "    var _I_ = 0; while (1) {switch (_I_) {case 0: ~%")
  (format out "    var ~A;~%" (transpiler-symbol-string tr
							  (transpiler-obfuscate-symbol tr '*CURRENT-FUNCTION*))))

(defun js-transpile-print-epilogue (out)
  (format out "    }break;}~%"))

(defun js-gen-funref-wrapper (out)
  (princ ,(concat-stringtree
		      (with-open-file i (open "environment/transpiler/targets/javascript/funref.js" :direction 'input)
			  	(read-all-lines i)))
		 out))

(defun js-transpile-prepare (tr out &key (import-universe? nil))
  (when import-universe?
    (transpiler-import-universe tr))
  (when (transpiler-lambda-export? tr)
    (transpiler-add-wanted-function tr 'array-copy)
    (js-gen-funref-wrapper out)))

(defun js-transpile-0 (f files &key (base? nil))
  (with (tr *js-transpiler*
    	 base (transpiler-sighten tr *js-base*)
    	 base2 (transpiler-sighten tr *js-base2*)
		 base-debug (when *transpiler-assert*
				      (transpiler-sighten tr *js-base-debug-print*))
		 tests (when (eq t *have-environment-tests*)
				 (transpiler-sighten tr (make-environment-tests)))
	 	 user (transpiler-sighten-files tr files)
		 deps (progn
				(format t "; Collecting dependencies...~%")
				(transpiler-import-from-environment tr)))
	; Generate.
    (format t "; Let me think. Hmm")
  	(force-output)
    (let no-decls 
	  (concat-stringtree
		  (when base?
 	        (transpiler-transpile tr base))
		  (when base?
 	        (transpiler-transpile tr base2))
 	      (transpiler-transpile tr deps)
		  (when (and base? *transpiler-assert*)
 		    (transpiler-transpile tr base-debug))
 	      (transpiler-transpile tr tests)
 	      (transpiler-transpile tr user))
	  (princ (concat-stringtree
			     (mapcar (fn transpiler-emit-code tr (list _))
						 (funinfo-var-declarations *global-funinfo*)))
	         f)
	  (princ no-decls f))
    (transpiler-print-obfuscations tr)))

(defun js-transpile-ok ()
  (format t "~%; Everything OK. ~A instructions. Done.~%"
			*codegen-num-instructions*))

(defun js-transpile (out files &key (obfuscate? nil) (env? nil))
  (let tr *js-transpiler*
    (setf *current-transpiler* tr)
    (transpiler-reset tr)
    (transpiler-switch-obfuscator tr obfuscate?)
	(make-global-funinfo)
    (setf *nil-symbol-name*
		  (symbol-name (transpiler-obfuscate-symbol-0 tr nil)))
;    (when (or env?
;			  (not *transpiler-assert*))
      (js-transpile-print-prologue out tr)
;)
;    (when (and *transpiler-assert*
;			   (not env?))
;	  (clr (transpiler-import-from-environment? tr)))
    (js-transpile-prepare tr out :import-universe? nil)
    (js-transpile-0 out files :base? t); :base? (or (not *transpiler-assert*)
								;		 env?))
;    (unless env?
      (js-transpile-print-epilogue out)
;)
	(js-transpile-ok)))
