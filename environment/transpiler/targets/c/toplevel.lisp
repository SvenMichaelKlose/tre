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
		   "builtin_function.h"
		   "builtin.h"
		   "builtin_image.h"
		   "builtin_list.h"
		   "builtin_net.h"
		   "builtin_number.h"
		   "builtin_sequence.h"
		   "builtin_stream.h"
		   "builtin_string.h"
		   "builtin_symbol.h"
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

(defun c-closure-argument-def (tr def)
  `(tresymbol_builtin_usetf_symbol_value
       (cons (list ,(compiled-tree (c-compile-symbols-in-tree .def)))
             (list (symbol-function ',def.)))))

(defun c-closure-argument-defs (tr)
  (filter [c-closure-argument-def tr _]
		  (transpiler-closure-argdefs tr)))

(defun c-function-registration (tr name)
  `(%setq ~%ret (treatom_register_compiled_function
                    ,(c-compiled-symbol name)
                    ,name
                    ,(alet (c-expander-name name)
                       (? (transpiler-defined-function tr !)
                          (compiled-function-name tr !)
                          '(%%native "NULL"))))))

(defun c-function-registrations (tr)
  (filter [c-function-registration tr _]
		  (remove-if [ends-with? (symbol-name _) "_TREEXP"]
                     (transpiler-defined-functions-without-builtins tr))))

(defun c-declarations-and-initialisations (tr)
  (+ (transpiler-compiled-inits tr)
     (c-function-registrations tr)
     (c-closure-argument-defs tr)))

(defun c-make-init-function (tr statements)
  (alet ($ 'C-INIT- (1+! *c-init-counter*))
    `(defun ,! ()
       ,@(mapcar ^(tregc_add_unremovable ,_) statements))))

(defun c-make-init-functions (tr)
  (with-temporary *c-init-counter* 0
    (+ (mapcar [c-make-init-function tr _]
			   (group (c-declarations-and-initialisations tr) *c-init-group-size*))
       `((defun c-init ()
           ,@(with-queue q
               (adotimes (*c-init-counter* (queue-list q))
                 (enqueue q `(,($ 'C-INIT- (1+ !)))))))))))

(defun c-compile-init-functions (tr)
  (with-temporary (transpiler-profile? tr) nil
    (transpiler-make-code tr (transpiler-frontend tr (c-make-init-functions tr)))))

(defun c-decl-gen (tr)
  (c-compile-symbols-in-tree (transpiler-closure-argdefs tr))
  (concat-stringtree (transpiler-compiled-decls tr)
                     (c-compile-init-functions tr)))


(defun c-header-includes ()
  (+ (format nil "#include <stdlib.h>~%")
     (apply #'+ (mapcar [format nil "#include \"~A\"~%" _] *c-core-headers*))))

(defun c-transpile (sources &key transpiler obfuscate? print-obfuscations? files-to-update)
  (let tr transpiler
    (+ (c-header-includes)
  	   (target-transpile tr :decl-gen #'(()
                                           (c-decl-gen tr))
                            :files-after-deps sources))))
