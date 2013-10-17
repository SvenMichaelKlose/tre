;;;;; tré – Copyright (c) 2008–2013 Sven Michael Klose <pixel@copei.de>

(defvar *c-init-group-size*  16)
(defvar *c-init-counter*      0)
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
		   "builtin_time.h"
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

(defun c-header-includes ()
  (+ (format nil "#include <stdlib.h>~%")
     (apply #'+ (mapcar [format nil "#include \"~A\"~%" _] *c-core-headers*))))

(defun c-function-registration (name)
  `(%= ~%ret (treatom_register_compiled_function
                 ,(c-compiled-symbol name)
                 ,name
                 ,(alet (c-expander-name name)
                    (? (transpiler-defined-function *transpiler* !)
                       (compiled-function-name !)
                       '(%%native "NULL"))))))

(defun c-function-registrations ()
  (filter #'c-function-registration
		  (remove-if [ends-with? (symbol-name _) "_TREEXP"]
                     (transpiler-defined-functions-without-builtins *transpiler*))))

(defun c-declarations-and-initialisations ()
  (+ (transpiler-compiled-inits *transpiler*)
     (c-function-registrations)))

(defun c-make-init-function (statements)
  (alet ($ 'C-INIT- (++! *c-init-counter*))
    `(defun ,! ()
       ,@(mapcar ^(tregc_add_unremovable ,_) statements))))

(defun c-make-init-functions ()
  (transpiler-add-used-function *transpiler* 'c-init)
  (with-temporary *c-init-counter* 0
    (+ (mapcar #'c-make-init-function
			   (group (c-declarations-and-initialisations) *c-init-group-size*))
       `((defun c-init ()
           ,@(with-queue q
               (adotimes (*c-init-counter* (queue-list q))
                 (enqueue q `(,($ 'C-INIT- (++ !)))))))))))

(defun c-compile-init-functions ()
  (alet *transpiler*
    (with-temporaries ((transpiler-profile? !)    nil
                       (transpiler-backtrace? !)  nil
                       (transpiler-assert? !)     nil
                       (transpiler-always-expand-arguments? !)  nil)
        (transpiler-make-code ! (transpiler-frontend ! (c-make-init-functions))))))

(defun c-decl-gen ()
  (concat-stringtree (transpiler-compiled-decls *transpiler*)
                     (c-compile-init-functions)))
