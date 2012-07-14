;;;;; tré – Copyright (c) 2008–2012 Sven Michael Klose <pixel@copei.de>

(defvar *bc-init-group-size* 16)
(defvar *bc-init-counter* 0)
(defvar *bc-interpreter-headers*
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

(define-tree-filter bc-transpiler-compile-argument-def-symbols (x)
  (& x (symbol? x)) (bc-compiled-symbol x))

(defun bc-transpiler-make-closure-argument-defs ()
  (filter (fn `(%setq-atom-value ,_. ,(compiled-tree (bc-transpiler-compile-argument-def-symbols ._))))
		  *closure-argdefs*))

(defun bc-transpiler-make-function-registrations (tr)
  (filter (fn `(%setq ~%ret
					  (treatom_register_compiled_function
						  ,(bc-compiled-symbol _)
						  ,_)))
		  (transpiler-defined-functions-without-builtins tr)))

(defun bc-transpiler-declarations-and-initialisations (tr)
  (append (transpiler-compiled-inits tr)
		  (bc-transpiler-make-closure-argument-defs)
		  (bc-transpiler-make-function-registrations tr)))

(defun bc-transpiler-make-init (tr)
  (let init-funs nil
    (append
        (mapcar (fn (with-gensym g
				      (let name ($ 'C-INIT- (1+! *bc-init-counter*))
				        (push name init-funs)
				        `(defun ,name ()
						   ,@(mapcar (fn `(tregc_push_compiled ,_)) _)))))
			    (group (bc-transpiler-declarations-and-initialisations tr) *bc-init-group-size*))
        `((defun bc-init ()
		    ,@(mapcar #'list (reverse init-funs)))))))

(defun bc-transpile (sources &key transpiler obfuscate? print-obfuscations? files-to-update)
  (let tr transpiler
    (string-concat
        (apply #'string-concat (mapcar (fn format nil "#include \"~A\"~%" _) *bc-interpreter-headers*))
  	    (format nil "#define userfun_apply trespecial_apply_compiled~%")
  	    (target-transpile tr
            :files-after-deps sources
            :dep-gen #'(()
                          (transpiler-import-from-environment tr))
            :decl-gen #'(()
                           (bc-transpiler-compile-argument-def-symbols *closure-argdefs*)
                           (let init (transpiler-make-code tr (transpiler-frontend tr (bc-transpiler-make-init tr)))
                             (concat-stringtree (transpiler-compiled-decls tr) init)))))))
