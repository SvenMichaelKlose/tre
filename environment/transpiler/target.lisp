;;;;; tré – Copyright (c) 2008–2013 Sven Michael Klose <pixel@copei.de>

(defvar *nil-symbol-name* "NIL")
(defvar *t-symbol-name*   "T")

(defun eq-string== (x y)
  (? (| (symbol? x)
        (symbol? y))
     (eq x y)
     (string== x y)))

(defun compile-section? (section processed-sections sections-to-update)
  (| (member section sections-to-update :test #'eq-string==)
     (not (assoc section processed-sections :test #'eq-string==))))

(defun accumulated-toplevel? (section)
  (not (eq 'accumulated-toplevel section)))

(defun target-transpile-2 (tr sections sections-to-update)
  (let compiled-code (make-queue)
	(dolist (i sections (queue-list compiled-code))
      (with-cons section data i
        (with-temporary (transpiler-current-section tr) section
          (let code (? (compile-section? section (transpiler-compiled-files tr) sections-to-update)
                       (with-temporary (transpiler-accumulate-toplevel-expressions? tr) (not (accumulated-toplevel? section))
                         (transpiler-make-code tr data))
                       (assoc-value section (transpiler-compiled-files tr) :test #'eq-string==))
            (aadjoin! code section (transpiler-compiled-files tr) :test #'eq-string==)
	        (enqueue compiled-code code)))))))

(defun target-transpile-1 (tr sections sections-to-update)
  (let frontend-code (make-queue)
	(dolist (i sections (queue-list frontend-code))
      (with-cons section data i
        (with-temporaries ((transpiler-current-section tr) section
                           (transpiler-current-section-data tr) data)
          (let code (? (compile-section? section (transpiler-frontend-files tr) sections-to-update)
                       (?
                         (symbol? section) (transpiler-frontend tr (? (function? data)
                                                                      (funcall data)
                                                                      data))
		  			     (string? section) (transpiler-frontend-file tr section)
                         (error "Compiler input is not described by a symbol (paired with a function or expressions) or a file name string. Got ~A instead." i.))
                       (assoc-value section (transpiler-frontend-files tr) :test #'eq-string==))
            (aadjoin! code section (transpiler-frontend-files tr) :test #'eq-string==)
	        (enqueue frontend-code (cons section code))))))))

(defun target-sighten-deps (tr dep-gen)
  (& dep-gen
     (with-temporary (transpiler-save-argument-defs-only? tr) nil
       (funcall dep-gen))))

(defun target-transpile-accumulated-toplevels (tr)
  (& (transpiler-accumulate-toplevel-expressions? tr)
     (transpiler-accumulated-toplevel-expressions tr)
	 (transpiler-make-code tr (target-transpile-1 tr (list (cons 'accumulated-toplevel
                                                                 #'(()
                                                                      (transpiler-make-toplevel-function tr))))
                                                     (list 'accumulated-toplevel)))))

(defun tell-number-of-warnings ()
  (alet (length *warnings*)
    (unless (zero? 1)
      (format t "; ~A warning~A.~%" ! (? (< 1 !) "s" "")))))

(defun target-transpile (tr &key (decl-gen nil)
                                 (files-before-deps nil)
                                 (dep-gen nil)
                                 (files-after-deps nil)
                                 (files-to-update nil)
                                 (obfuscate? nil)
                                 (print-obfuscations? nil))
  (= *warnings* nil)
  (with-temporaries (*recompiling?*  (? files-to-update t)
                     *transpiler*    tr
                     *assert*        (| *assert* (transpiler-assert? tr))
                     dep-gen         (| dep-gen #'(()
                                                    (transpiler-import-from-environment tr))))
    (& *have-compiler?* (= (transpiler-save-sources? tr) t))
    (& files-to-update  (clr (transpiler-emitted-decls tr)))
    (= (transpiler-host-functions-hash tr) (make-host-functions-hash))
    (= (transpiler-host-variables-hash tr) (make-host-variables-hash))
    (transpiler-switch-obfuscator tr obfuscate?)
    (with (before-deps  (target-transpile-1 tr files-before-deps files-to-update)
		   after-deps   (target-transpile-1 tr files-after-deps files-to-update)
		   deps         (target-sighten-deps tr dep-gen)
           num-exprs    (apply #'+ (mapcar [length ._] (+ before-deps deps after-deps))))
      (& *show-transpiler-progress?*
         (format t "; ~A top level expressions.~%; Let me think. Hmm...~F" num-exprs))
      (with (compiled-before  (target-transpile-2 tr before-deps files-to-update)
	         compiled-deps    (!? deps (transpiler-make-code tr !))
		     compiled-after   (target-transpile-2 tr after-deps files-to-update)
             compiled-acctop  (target-transpile-accumulated-toplevels tr))
        (& *show-transpiler-progress?* (format t " Phew!~%~F"))
        (!? compiled-deps
            (= (transpiler-imported-deps tr) (transpiler-concat-text tr (transpiler-imported-deps tr) !)))
        (let decls-and-inits (!? decl-gen (funcall !))
	      (prog1
	        (transpiler-concat-text tr decls-and-inits
	                                   compiled-before
                                       (reverse (transpiler-raw-decls tr))
                                       (transpiler-imported-deps tr)
	                                   compiled-after
                                       compiled-acctop)
            (& print-obfuscations?
               (transpiler-obfuscate? tr)
               (transpiler-print-obfuscations tr))
            (warn-unused-functions tr)
            (tell-number-of-warnings)))))))
