;;;;; tré – Copyright (c) 2008–2013 Sven Michael Klose <pixel@copei.de>

(defvar *nil-symbol-name* "NIL")
(defvar *t-symbol-name*   "T")

(defun eq-string== (x y)
  (? (| (symbol? x)
        (symbol? y))
     (eq x y)
     (string== x y)))

(defun compile-section? (section processed-sections)
  (| (member section (transpiler-sections-to-update *transpiler*) :test #'eq-string==)
     (not (assoc section processed-sections :test #'eq-string==))))

(defun accumulated-toplevel? (section)
  (not (eq 'accumulated-toplevel section)))

(defun target-transpile-2 (sections)
  (with (tr             *transpiler*
         compiled-code  (make-queue))
	(dolist (i sections (queue-list compiled-code))
      (with-cons section data i
        (with-temporary (transpiler-current-section tr) section
          (let code (? (compile-section? section (transpiler-compiled-files tr))
                       (with-temporary (transpiler-accumulate-toplevel-expressions? tr) (not (accumulated-toplevel? section))
                         (transpiler-make-code tr data))
                       (assoc-value section (transpiler-compiled-files tr) :test #'eq-string==))
            (aadjoin! code section (transpiler-compiled-files tr) :test #'eq-string==)
	        (enqueue compiled-code code)))))))

(defun target-transpile-1 (sections)
  (with (tr             *transpiler*
         frontend-code  (make-queue))
	(dolist (i sections (queue-list frontend-code))
      (with-cons section data i
        (with-temporaries ((transpiler-current-section tr) section
                           (transpiler-current-section-data tr) data)
          (let code (? (compile-section? section (transpiler-frontend-files tr))
                       (?
                         (symbol? section) (transpiler-frontend tr (? (function? data)
                                                                      (funcall data)
                                                                      data))
		  			     (string? section) (transpiler-frontend-file tr section)
                         (error "Compiler input is not described by a section symbol with a function or expressions by a file name. Got ~A instead." i.))
                       (assoc-value section (transpiler-frontend-files tr) :test #'eq-string==))
            (aadjoin! code section (transpiler-frontend-files tr) :test #'eq-string==)
	        (enqueue frontend-code (cons section code))))))))

(defun target-sighten-deps ()
  (with-temporary (transpiler-save-argument-defs-only? *transpiler*) nil
    (transpiler-import-from-environment *transpiler*)))

(defun target-transpile-accumulated-toplevels (tr)
  (& (transpiler-accumulate-toplevel-expressions? tr)
     (transpiler-accumulated-toplevel-expressions tr)
     (with-temporary (transpiler-sections-to-update tr) '(accumulated-toplevel)
	   (transpiler-make-code tr (target-transpile-1 (list (cons 'accumulated-toplevel
                                                                #'(()
                                                                     (transpiler-make-toplevel-function tr)))))))))

(defun tell-number-of-warnings ()
  (alet (length *warnings*)
    (unless (zero? 1)
      (format t "; ~A warning~A.~%" ! (? (< 1 !) "s" "")))))

(defun target-transpile (tr sections)
  (let start-time (nanotime)
    (= *warnings* nil)
    (with-temporaries (*recompiling?*  (& (transpiler-sections-to-update tr) t)
                       *transpiler*    tr
                       *assert*        (| *assert* (transpiler-assert? tr)))
      (& *have-compiler?*
         (= (transpiler-save-sources? tr) t))
      (& (transpiler-sections-to-update tr)
         (clr (transpiler-emitted-decls tr)))
      (= (transpiler-host-functions-hash tr) (make-host-functions-hash))
      (= (transpiler-host-variables-hash tr) (make-host-variables-hash))
      (with (before-deps  (target-transpile-1 (!? (transpiler-sections-before-deps tr)
                                                  (funcall ! tr)))
		     after-deps   (target-transpile-1 (+ (!? (transpiler-sections-after-deps tr)
                                                     (funcall ! tr))
                                                 sections))
		     deps         (target-sighten-deps))
        (& *show-transpiler-progress?*
           (let num-exprs (apply #'+ (mapcar [length ._]
                                             (+ before-deps deps after-deps)))
             (format t "; ~A top level expressions.~%; Let me think. Hmm...~%" num-exprs)))
        (with (compiled-before  (target-transpile-2 before-deps)
	           compiled-deps    (!? deps
                                    (transpiler-make-code tr !))
               compiled-after   (target-transpile-2 after-deps)
               compiled-acctop  (target-transpile-accumulated-toplevels tr))
        (& *show-transpiler-progress?* (format t "; Phew!~%"))
          (!? compiled-deps
              (= (transpiler-imported-deps tr) (transpiler-concat-text tr (transpiler-imported-deps tr) !)))
          (prog1
            (transpiler-concat-text tr (funcall (| (transpiler-prologue-gen tr)
                                                   #'(() "")))
                                       (!? (transpiler-decl-gen tr)
                                           (funcall !))
                                       compiled-before
                                       (reverse (transpiler-raw-decls tr))
                                       (transpiler-imported-deps tr)
                                       compiled-after
                                       compiled-acctop
                                       (funcall (| (transpiler-epilogue-gen tr)
                                                   #'(() ""))))
              (& (transpiler-print-obfuscations? tr)
                 (transpiler-obfuscate? tr)
                 (transpiler-print-obfuscations tr))
              (warn-unused-functions tr)
              (tell-number-of-warnings)
              (& *show-transpiler-progress?*
                 (format t "; ~A seconds passed.~%~F" (integer (/ (- (nanotime) start-time) 1000000000))))))))))
