;;;;; tré – Copyright (c) 2008–2012 Sven Michael Klose <pixel@copei.de>

(defvar *closure-argdefs* nil)
(defvar *c-init-group-size* 16)
(defvar *c-init-counter* 0)
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
		   "builtin_net.h"
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
		   "alien.h"
		   "compiled.h"))

(define-tree-filter c-transpiler-compile-argument-def-symbols (x)
  (& x (symbol? x)) (c-compiled-symbol x))

(defun c-transpiler-make-closure-argument-defs ()
  (filter (fn `(%setq-atom-value ,_. ,(compiled-tree (c-transpiler-compile-argument-def-symbols ._))))
		  *closure-argdefs*))

(defun c-transpiler-make-function-registrations (tr)
  (filter (fn `(%setq ~%ret
					  (treatom_register_compiled_function
						  ,(c-compiled-symbol _)
						  ,_)))
		  (transpiler-defined-functions-without-builtins tr)))

(defun c-transpiler-declarations-and-initialisations (tr)
  (append (transpiler-compiled-inits tr)
		  (c-transpiler-make-closure-argument-defs)
		  (c-transpiler-make-function-registrations tr)))

(defun c-transpiler-make-init (tr)
  (let init-funs nil
    (append
        (mapcar (fn (with-gensym g
				      (let name ($ 'C-INIT- (1+! *c-init-counter*))
				        (push name init-funs)
				        `(defun ,name ()
						   ,@(mapcar (fn `(tregc_push_compiled ,_)) _)))))
			    (group (c-transpiler-declarations-and-initialisations tr) *c-init-group-size*))
        `((defun c-init ()
		    ,@(mapcar #'list (reverse init-funs)))))))

(defun c-transpile (sources &key transpiler obfuscate?)
  (let tr transpiler
    (string-concat
        (apply #'string-concat (mapcar (fn format nil "#include \"~A\"~%" _) *c-interpreter-headers*))
  	    (format nil "#define userfun_apply trespecial_apply_compiled~%")
  	    (target-transpile tr
            :files-after-deps sources
            :dep-gen #'(()
                          (transpiler-import-from-environment tr))
            :decl-gen #'(()
                           (c-transpiler-compile-argument-def-symbols *closure-argdefs*)
                           (let init (transpiler-make-code tr (transpiler-frontend tr (c-transpiler-make-init tr)))
                             (concat-stringtree (transpiler-compiled-decls tr) init)))))))
