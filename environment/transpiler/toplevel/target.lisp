;;;;; tré – Copyright (c) 2008-2012 Sven Michael Klose <pixel@copei.de>

(defvar *nil-symbol-name* "NIL")
(defvar *t-symbol-name* "T")

(defun eq-string== (x y)
  (? (| (symbol? x)
        (symbol? y))
     (eq x y)
     (string== x y)))

(defun compile-file? (file processed-files files-to-update)
  (| (member file files-to-update :test #'eq-string==)
     (not (assoc file processed-files :test #'eq-string==))))

(defun target-transpile-2 (tr files files-to-update)
  (let compiled-code (make-queue)
	(dolist (i files (queue-list compiled-code))
      (let code (? (compile-file? i. (transpiler-compiled-files tr) files-to-update)
                   (with-temporary (transpiler-accumulate-toplevel-expressions? tr) (not (eq 'accumulated-toplevel i.))
                     (transpiler-make-code tr .i))
                   (assoc-value i. (transpiler-compiled-files tr) :test #'eq-string==))
        (assoc-adjoin code i. (transpiler-compiled-files tr) :test #'eq-string==)
	    (enqueue compiled-code code)))))

(defun target-transpile-1 (tr files files-to-update)
  (let frontend-code (make-queue)
	(dolist (i files (queue-list frontend-code))
      (let code (? (compile-file? i. (transpiler-frontend-files tr) files-to-update)
                   (? (symbol? i.)
                      (transpiler-frontend tr (? (function? .i) (funcall .i) .i))
		  			  (transpiler-frontend-file tr i.))
                   (assoc-value i. (transpiler-frontend-files tr) :test #'eq-string==))
        (assoc-adjoin code i. (transpiler-frontend-files tr) :test #'eq-string==)
	    (enqueue frontend-code (cons i. code))))))

(defun target-sighten-deps (tr dep-gen)
  (& dep-gen
     (with-temporary (transpiler-save-argument-defs-only? tr) nil
       (funcall dep-gen))))

(defun target-transpile (tr &key (files-before-deps nil)
                                 (files-after-deps nil)
                                 (files-to-update nil)
                                 (dep-gen nil)
                                 (decl-gen nil)
                                 (obfuscate? nil)
                                 (print-obfuscations? nil))
  (with-temporaries (*recompiling?* (? files-to-update t)
                     *current-transpiler* tr)
    (& *have-compiler?*
       (= (transpiler-save-sources? tr) t))
    (& files-to-update
       (clr (transpiler-emitted-decls tr)))
    (transpiler-switch-obfuscator tr obfuscate?)
    (with (before-deps (target-transpile-1 tr files-before-deps files-to-update)
		   after-deps  (target-transpile-1 tr files-after-deps files-to-update)
		   deps        (target-sighten-deps tr dep-gen)
           num-exprs   (apply #'+ (mapcar (fn length ._) (append before-deps deps after-deps)))
           show?       #'(() (& *show-definitions?* (< 50 num-exprs))))
      (& (show?)
         (format t "; ~A toplevel expressions.~%; Let me think. Hmm...~F" num-exprs))
      (with (compiled-before (target-transpile-2 tr before-deps files-to-update)
	         compiled-deps   (awhen deps (transpiler-make-code tr !))
		     compiled-after  (target-transpile-2 tr after-deps files-to-update)
           )
;           compiled-acctop (when (transpiler-accumulate-toplevel-expressions? tr)
;	                         (transpiler-make-code tr 
;                                 (target-transpile-1 tr (list (cons 'accumulated-toplevel #'(()
;                                                                                              (transpiler-make-toplevel-function tr))))
;                                                     (list 'accumulated-toplevel)))))
        (& (show?) (format t " Phew!~%~F"))
        (!? compiled-deps
            (= (transpiler-imported-deps tr) (transpiler-concat-text tr (transpiler-imported-deps tr) !)))
        (let decls-and-inits (!? decl-gen (funcall !))
          (& (show?) (format t "; Concatenating results...~F"))
	      (prog1
	        (transpiler-concat-text tr decls-and-inits
	                                   compiled-before
                                       (reverse (transpiler-raw-decls tr))
                                       (transpiler-imported-deps tr)
	                                   compiled-after)
                                       ;(| compiled-acctop ""))
            (& (show?) (format t " Done.~%~F"))
            (& print-obfuscations? (transpiler-obfuscate? tr)
               (transpiler-print-obfuscations tr))))))))
