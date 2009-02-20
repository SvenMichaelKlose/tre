;;;;; Transpiler: TRE to JavaScript
;;;;; Copyright (c) 2008-2009 Sven Klose <pixel@copei.de>
;;;;;
;;;;; Toplevel

(defun js-transpile-0 (f files)
  (format f "/*~%")
  (format f " * Copyright (c) 2005-2008 Sven Klose <pixel@copei.de>~%")
  (format f " *~%")
  (format f " * Softwarearchitekturbuero Sven Klose~%")
  (format f " * Westermuehlstrasse 31~%")
  (format f " * D-80469 Muenchen~%")
  (format f " * Tel.: ++49 / 89 / 57 08 22 38~%")
  (format f " *~%")
  (format f " * caroshi ECMAScript obfuscator~%")
  (format f " */~%")
  (format f "function T37funref (f, g) { var r=function () { var a = arrayCopy (arguments); a.unshift (g); return f.apply (null, a); }; r.treArgs = f.treArgs; return r; }~%")
  (format f "var _I_ = 0; while (1) {switch (_I_) {case 0: ~%")
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
    (princ (transpiler-concat-string-tree
 		     (transpiler-transpile tr base)
		     (transpiler-transpile tr deps)
 		     (transpiler-transpile tr base2)
			 (transpiler-transpile tr tests)
 		     (transpiler-transpile tr user))
	       f))
  (format f "}break;}~%")
  (format t "~%; Everything OK. Done.~%"l))

(defun js-transpile (out files &key (obfuscate? nil))
  (transpiler-reset *js-transpiler*)
  (transpiler-switch-obfuscator *js-transpiler* obfuscate?)
  (js-transpile-0 out files))

;; XXX defunct
(defun js-machine (outfile)
  (with-open-file f (open outfile :direction 'output)
    (format f "~A"
			(transpiler-concat-strings
			  (transpiler-wanted *js-transpiler* #'transpiler-expand-and-generate-code (reverse *UNIVERSE*))))))
