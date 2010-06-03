;;;;; Transpiler: TRE to JavaScript
;;;;; Copyright (c) 2008-2010 Sven Klose <pixel@copei.de>
;;;;;
;;;;; Toplevel

(defvar *closure-argdefs* nil)
(defvar *c-init-group-size* 64)

(defun c-transpiler-get-argdef-symbols (x)
  (when x
	(if (atom x)
		(if (symbol-name x)
		    (c-compiled-symbol x)
			x)
		(cons (c-transpiler-get-argdef-symbols x.)
		  	  (c-transpiler-get-argdef-symbols .x)))))

(defun c-transpiler-spot-argdef-symbols (x)
  (when x
	(if (atom x)
		(when (symbol-name x)
		  (c-compiled-symbol x))
		(progn
		  (c-transpiler-spot-argdef-symbols x.)
		  (c-transpiler-spot-argdef-symbols .x)))))

(defun c-transpiler-make-closure-argdef-symbols ()
  (c-transpiler-spot-argdef-symbols *closure-argdefs*))

(defun c-transpiler-compiled-inits ()
  (transpiler-compiled-inits *c-transpiler*))

(defun c-transpiler-closure-argument-definitions ()
  (mapcar (fn `(%setq-atom-value
				   ,_.
				   ,(compiled-tree (c-transpiler-get-argdef-symbols ._))))
		  *closure-argdefs*))

(defun c-transpiler-register-functions ()
  (mapcar (fn `(%setq ~%ret
					  (treatom_register_compiled_function
						  ,(c-compiled-symbol _)
						  ,(compiled-function-name _))))
		  (remove-if #'builtinp
					 (transpiler-defined-functions *c-transpiler*))))

(defun c-transpiler-declarations-and-initialisations ()
  (append (c-transpiler-compiled-inits)
		  (c-transpiler-closure-argument-definitions)
		  (c-transpiler-register-functions)))

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
		   "macro.h"
		   "number.h"
		   "special.h"
		   "string2.h"
		   "io.h"
		   "main.h"
		   "xxx.h"
		   "compiled.h"))

(defun c-transpiler-make-init (tr)
  (let init-funs nil
    (append
        (mapcar (fn (with-gensym g
				      (let name ($ 'c-init- g)
				        (push! name init-funs)
				        `(defun ,name ()
						   ,@(mapcar (fn `(tregc_push_compiled ,_))
					       			 _)))))
			    (group (c-transpiler-declarations-and-initialisations)
					   *c-init-group-size*))
        `((defun c-init ()
		    ,@(mapcar #'list (reverse init-funs)))))))

(defun c-transpile-0 (f files)
  (map (fn (format f "#include \"~A\"~%" _))
	   *c-interpreter-headers*)
  (format f "#define compiled_apply trespecial_apply_compiled~%")
  (c-compiled-symbol 'fnord)
  (with (tr *c-transpiler*
		 ; Expand.
		 tests (when (eq t *have-environment-tests*)
				 (transpiler-sighten tr (make-environment-tests)))
	 	 usr (transpiler-sighten-files tr files)
		 deps (progn
				(format t "; Collecting dependencies...~%")
				(transpiler-import-from-environment tr))
		 decls (transpiler-sighten tr (transpiler-compiled-decls tr)))
	; Generate.
    (format t "; Let me think. Hmm")
    (let code (concat-stringtree
				  (transpiler-transpile tr deps)
		     	  (transpiler-transpile tr tests)
 	         	  (transpiler-transpile tr usr))
	  (c-transpiler-make-closure-argdef-symbols)
	  (setf *opt-inline?* nil)
	  (let cinit (c-transpiler-make-init tr)
	    (let init (transpiler-transpile tr (transpiler-sighten tr cinit))
	      (princ (concat-stringtree (transpiler-compiled-decls tr)
			       				    init code)
	             f)))))
  (format t "~%; Everything OK. Done.~%"))

(defun c-transpile (out files &key (obfuscate? nil))
  (with-temporary *current-transpiler* *c-transpiler*
    (transpiler-reset *c-transpiler*)
    (transpiler-switch-obfuscator *c-transpiler* obfuscate?)
    (make-global-funinfo)
    (c-transpile-0 out files)))
