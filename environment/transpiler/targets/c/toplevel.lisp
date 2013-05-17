;;;;; tré – Copyright (c) 2008–2013 Sven Michael Klose <pixel@copei.de>

(defvar *c-init-group-size* 16)
(defvar *c-init-counter* 0)
(defvar *c-core-headers*
	     '("ptr.h"
		   "cons.h"
		   "list.h"
		   "alloc.h"
		   "apply.h"
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
		   "symbol.h"
		   "io.h"
		   "main.h"
		   "xxx.h"
		   "alien.h"
		   "function.h"
		   "compiled.h"))

(define-tree-filter c-compile-symbols-in-tree (x)
  (& x (symbol? x)) (c-compiled-symbol x))

(defun c-closure-argument-defs (tr)
  (filter ^(treatom_builtin_usetf_symbol_value (cons (list ,(compiled-tree (c-compile-symbols-in-tree ._)))
                                                     (list (symbol-function ',_.))))
		  (transpiler-closure-argdefs tr)))

(defun c-function-registrations (tr)
  (filter ^(%setq ~%ret (treatom_register_compiled_function ,(c-compiled-symbol _) ,_ ,(alet ($ _ '_treexp)
                                                                                         (? (transpiler-defined-function tr !)
                                                                                            (compiled-user-function-name !)
                                                                                            '(%transpiler-native "NULL")))))
		  (remove-if [ends-with? (symbol-name _) "_TREEXP"]
                     (transpiler-defined-functions-without-builtins tr))))

(defun c-declarations-and-initialisations (tr)
  (+ (transpiler-compiled-inits tr)
     (c-function-registrations tr)
     (c-closure-argument-defs tr)))

(defun c-make-init-functions (tr)
  (let init-funs nil
    (+ (mapcar [with-gensym g
				 (let name ($ 'C-INIT- (1+! *c-init-counter*))
				   (push name init-funs)
				   `(defun ,name ()
				      ,@(mapcar ^(tregc_add_unremovable ,_) _)))]
			   (group (c-declarations-and-initialisations tr) *c-init-group-size*))
       `((defun c-init ()
	       ,@(mapcar #'list (reverse init-funs)))))))

(defun c-header-inclusions ()
  (+ (format nil "#include <stdlib.h>~%")
     (apply #'+ (mapcar [format nil "#include \"~A\"~%" _] *c-core-headers*))))

(defun c-transpile (sources &key transpiler obfuscate? print-obfuscations? files-to-update)
  (let tr transpiler
    (+ (c-header-inclusions)
  	   (target-transpile tr
           :decl-gen #'(()
                          (c-compile-symbols-in-tree (transpiler-closure-argdefs tr))
                          (let init (with-temporary (transpiler-profile? tr) nil
                                      (transpiler-make-code tr (transpiler-frontend tr (c-make-init-functions tr))))
                            (concat-stringtree (transpiler-compiled-decls tr) init)))
           :files-after-deps sources))))
