;;;;; Transpiler: TRE to JavaScript
;;;;; Copyright (c) 2008-2009 Sven Klose <pixel@copei.de>
;;;;;
;;;;; Toplevel

(defvar *closure-argdefs* nil)

(defun c-transpiler-get-argdef-symbols (x)
  (when x
	(if (atom x)
		(if (symbol-name x)
		    (c-compiled-symbol x)
			x)
		(cons (c-transpiler-get-argdef-symbols x.)
		  	  (c-transpiler-get-argdef-symbols .x)))))

(defun c-transpiler-register-functions (inits)
	(append inits
			(mapcar (fn `(%setq ~%ret
								(treatom_register_compiled_function
									,(c-compiled-symbol _)
									,(c-transpiler-function-name _))))
					(transpiler-defined-functions *c-transpiler*))
			(mapcar (fn `(%setq-atom-value
							 ,_.
							 ,(compiled-tree
								  (c-transpiler-get-argdef-symbols ._))))
					*closure-argdefs*)
			'((say-hello))))

(defvar *c-interpreter-headers*
	     '("ptr.h"
		   "list.h"
		   "array.h"
		   "atom.h"
		   "eval.h"
		   "gc.h"
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
		   "string2.h"
		   "compiled.h"))

(defvar in-c-init nil)

(defun c-transpile-0 (f files)
  (map (fn (format f "#include \"~A\"~%" _))
	   *c-interpreter-headers*)
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
		 decls (transpiler-sighten tr
				   (transpiler-compiled-decls tr)))
	; Generate.
    (format t "; Let me think. Hmm")
    (force-output)
	(c-compiled-symbol 'say-hello)
    (with (code (append (transpiler-transpile tr deps)
		     		    (transpiler-transpile tr tests)
 	         		    (transpiler-transpile tr usr)))
	  (mapcar (fn c-transpiler-get-argdef-symbols _)
			  *closure-argdefs*)
(setf in-c-init t)
	  (with (init (transpiler-transpile tr
 					(transpiler-sighten tr
				        `((defun c-init ()
					        ,@(c-transpiler-register-functions
								  (transpiler-compiled-inits tr)))))))
	  (princ (concat-stringtree
				 (transpiler-compiled-decls tr)
			     init
			     code)
	         f))))
  (format t "~%; Everything OK. Done.~%"))

(defun c-transpile (out files &key (obfuscate? nil))
  (setf *current-transpiler* *c-transpiler*)
  (transpiler-reset *c-transpiler*)
  (transpiler-switch-obfuscator *c-transpiler* obfuscate?)
  (c-transpile-0 out files))
