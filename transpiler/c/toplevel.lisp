;;;;; Transpiler: TRE to JavaScript
;;;;; Copyright (c) 2008-2009 Sven Klose <pixel@copei.de>
;;;;;
;;;;; Toplevel

(defvar *c-declarations* nil)
(defvar *c-init* nil)

(defun c-transpiler-register-functions (inits)
	(append inits
			(mapcar (fn `(%setq ~%ret
								(treatom_register_compiled_function
								,(c-compiled-symbol _)
								,(c-transpiler-function-name _))))
					(transpiler-defined-functions *c-transpiler*))))

(defun c-transpile-0 (f files)
  (with-temporary *lambda-expand-always-have-funref* t
    (format f "/*~%")
    (format f " * Copyright (c) 2005-2009 Sven Klose <pixel@copei.de>~%")
    (format f " *~%")
    (format f " * Softwarearchitekturbuero Sven Klose~%")
    (format f " * Westermuehlstrasse 31~%")
    (format f " * D-80469 Muenchen~%")
    (format f " * Tel.: ++49 / 89 / 57 08 22 38~%")
    (format f " */~%")
    (format f "#define cons _trelist_get~%")
    (map (fn (format f "#include \"~A\"~%" _))
	     '(
		   "ptr.h"
		   "list.h"
		   "atom.h"
		   "eval.h"
		   "builtin_arith.h"
		   "builtin_array.h"
		   "builtin_atom.h"
		   "builtin_debug.h"
		   "builtin_error.h"
		   "builtin_fileio.h"
		   "builtin.h"
		   "builtin_image.h"
		   "builtin_list.h"
		   "builtin_number.h"
		   "builtin_sequence.h"
		   "builtin_stream.h"
		   "builtin_string.h"
		   "special.h"
		   "string2.h"))
;    (dolist (i (reverse *universe*))
;  	  (when (functionp (symbol-function i))
;  	    (transpiler-add-wanted-function *c-transpiler* i)))
    (with (tr *c-transpiler*
		   ; Expand.
		   tests (when (eq t *have-environment-tests*)
				   (transpiler-sighten tr (make-environment-tests)))
	 	   usr (transpiler-sighten-files tr files)
		   deps (progn
				  (format t "; Collecting dependencies...~%")
				  (transpiler-import-from-environment tr))
		   decls (transpiler-sighten tr *c-declarations*))
	    ; Generate.
	    (format t "; Let me think. Hmm")
	    (force-output)
        (with (code (append (transpiler-transpile tr deps)
			     		    (transpiler-transpile tr tests)
 		         		    (transpiler-transpile tr usr))
		 	   init (transpiler-transpile tr
 					    (transpiler-sighten tr
				            `((defun c-init ()
					            ,@(c-transpiler-register-functions *c-init*))))))
          (princ (concat-stringtree
		  			 *c-declarations*
				     init
				     code)
	             f)))
      (format t "~%; Everything OK. Done.~%")))

(defun c-transpile (out files &key (obfuscate? nil))
  (transpiler-reset *c-transpiler*)
  (transpiler-switch-obfuscator *c-transpiler* obfuscate?)
  (c-transpile-0 out files))
