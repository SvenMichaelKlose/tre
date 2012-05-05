;;;;; tré - Copyright (c) 2008-2012 Sven Michael Klose <pixel@copei.de>

(defvar *closure-argdefs* nil)
(defvar *c-init-group-size* 16)
(defvar *c-init-counter* 0)

(define-tree-filter c-transpiler-get-argdef-symbols (x)
  (not x)
    x
  (and (atom x)
	   (symbol-name x))
    (c-compiled-symbol x))

(defun c-transpiler-spot-argdef-symbols (x)
  (when x
	(? (atom x)
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
						  ,_)))
		  (transpiler-defined-functions-without-builtins *c-transpiler*)))

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

(defun c-transpiler-make-init (tr)
  (let init-funs nil
    (append
        (mapcar (fn (with-gensym g
				      (let name ($ 'C-INIT- (1+! *c-init-counter*))
				        (push name init-funs)
				        `(defun ,name ()
						   ,@(mapcar #'((x)
                                         `(tregc_push_compiled ,x))
                                     _)))))
			    (group (c-transpiler-declarations-and-initialisations) *c-init-group-size*))
        `((defun c-init ()
		    ,@(mapcar #'list (reverse init-funs)))))))

(defun c-transpile (sources &key (obfuscate? nil))
  (let tr *c-transpiler*
	(with-temporary *current-transpiler* tr
      (string-concat (apply #'string-concat (mapcar (fn format nil "#include \"~A\"~%" _) *c-interpreter-headers*))
  	                 (format nil "#define userfun_apply trespecial_apply_compiled~%")
  	                 (target-transpile *c-transpiler*
	  	                 :files-after-deps sources
	                     :dep-gen #'(()
			                          (transpiler-import-from-environment tr))
	                     :decl-gen #'(()
			                          (c-transpiler-make-closure-argdef-symbols)
			                          (let init (transpiler-make-code tr (transpiler-frontend tr (c-transpiler-make-init tr)))
		   	                            (concat-stringtree (transpiler-compiled-decls tr) init))))))))
