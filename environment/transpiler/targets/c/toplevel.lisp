; tré – Copyright (c) 2008–2014 Sven Michael Klose <pixel@copei.de>

(defvar *c-init-group-size*  16)
(defvar *c-init-counter*      0)
(defvar *c-core-headers*
	     '("ptr.h"
		   "cons.h"
		   "list.h"
		   "alloc.h"
		   "array.h"
		   "assert.h"
		   "atom.h"
		   "funcall.h"
		   "exception.h"
		   "gc.h"
		   "backtrace.h"
		   "builtin_apply.h"
		   "builtin_arith.h"
		   "builtin_array.h"
		   "builtin_atom.h"
		   "builtin_error.h"
		   "builtin_fs.h"
		   "builtin_function.h"
		   "builtin.h"
		   "builtin_list.h"
		   "builtin_memory.h"
		   "builtin_net.h"
		   "builtin_number.h"
		   "builtin_sequence.h"
		   "builtin_stream.h"
		   "builtin_string.h"
		   "builtin_symbol.h"
		   "builtin_terminal.h"
		   "builtin_time.h"
		   "number.h"
		   "string2.h"
		   "symtab.h"
		   "symbol.h"
		   "xxx.h"
		   "alien.h"
		   "function.h"
		   "stream.h"
		   "main.h"
		   "compiled.h"))

(defun c-header-includes ()
  (+ (format nil "#include <stdlib.h>~%")
     (format nil "#include <stdio.h>~%")
     (apply #'+ (mapcar [format nil "#include \"~A\"~%" _] *c-core-headers*))))

(defun c-function-registration (name)
  `(%= ~%ret (register_compiled_function
                 ,(c-compiled-symbol name)
                 ,name
                 ,(alet (c-expander-name name)
                    (? (defined-function !)
                       (compiled-function-name !)
                       '(%%native "NULL"))))))

(defun c-function-registrations ()
  (filter #'c-function-registration
		  (remove-if [tail? (symbol-name _) "_TREEXP"]
                     (defined-functions-without-builtins))))

(defun c-declarations-and-initialisations ()
  (+ (compiled-inits)
     (c-function-registrations)))

(defun c-make-init-function (statements)
  (alet ($ 'C-INIT- (++! *c-init-counter*))
    `(defun ,! ()
       ,@(mapcar [`(tregc_add_unremovable ,_)]
                 statements))))

(defun c-make-init-functions ()
  (add-used-function 'c-init)
  (with-temporary *c-init-counter* 0
    (+ (mapcar #'c-make-init-function
			   (group (c-declarations-and-initialisations) *c-init-group-size*))
       `((defun c-init ()
           ,@(with-queue q
               (adotimes (*c-init-counter* (queue-list q))
                 (enqueue q `(,($ 'C-INIT- (++ !)))))))))))

(defun c-compile-init-functions ()
  (with-temporaries ((profile?)                  nil
                     (backtrace?)                nil
                     (assert?)                   nil
                     (always-expand-arguments?)  nil)
      (backend (middleend (frontend (c-make-init-functions))))))

(defun c-decl-gen ()
  (concat-stringtree (compiled-decls)
                     (c-compile-init-functions)))

(defun c-expex-setter-filter ()
  (compose [mapcan #'expex-set-global-variable-value _]
           #'expex-compiled-funcall))

(defun c-expex-initializer (ex)
  (= (expex-argument-filter ex) #'c-argument-filter
     (expex-setter-filter ex) (c-expex-setter-filter)))

(defun c-identifier-char? (x)
  (| (<= #\a x #\z)
     (<= #\A x #\Z)
     (<= #\0 x #\9)
     (in=? x #\_ #\. #\$ #\#)))

(defun make-c-transpiler ()
  (create-transpiler
      :name                     :c
      :prologue-gen             #'c-header-includes
      :decl-gen                 #'c-decl-gen
      :sections-before-import   #'(()
                                     (list (. 'builtin-wrappers
                                              (c-make-builtin-wrappers))))
      :lambda-export?           t
      :stack-locals?            t
      :copy-arguments-to-stack? t
      :import-variables?        nil
      :identifier-char?         #'c-identifier-char?
      :expex-initializer        #'c-expex-initializer
      :backtrace?		        t))

(defvar *c-transpiler* (copy-transpiler (make-c-transpiler)))
(defvar *c-separator*  (+ ";" *newline*))
(defvar *c-indent*     "    ")
