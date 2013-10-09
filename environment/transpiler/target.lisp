;;;;; tré – Copyright (c) 2008–2013 Sven Michael Klose <pixel@copei.de>

(defvar *nil-symbol-name* "NIL")
(defvar *t-symbol-name*   "T")

(defun eq|string== (x y)
  (? (| (symbol? x)
        (symbol? y))
     (eq x y)
     (string== x y)))

(defun compile-section? (section processed-sections)
  (| (member section (transpiler-sections-to-update *transpiler*) :test #'eq|string==)
     (not (assoc section processed-sections :test #'eq|string==))))

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
                       (assoc-value section (transpiler-compiled-files tr) :test #'eq|string==))
            (aadjoin! code section (transpiler-compiled-files tr) :test #'eq|string==)
	        (enqueue compiled-code code)))))))

(def-transpiler target-transpile-1 (sections)
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
                       (assoc-value section (transpiler-frontend-files tr) :test #'eq|string==))
            (aadjoin! code section (transpiler-frontend-files tr) :test #'eq|string==)
	        (enqueue frontend-code (cons section code))))))))

(defun target-sighten-deps (tr)
  (with-temporary (transpiler-save-argument-defs-only? tr) nil
    (transpiler-import-from-environment tr)))

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

(def-transpiler transpile-codegen (transpiler before-deps deps after-deps)
  (& *show-transpiler-progress?*
     (format t "; Let me think. Hmm...~%"))
  (!? middleend-init (funcall !))
  (with (compiled-before  (target-transpile-2 before-deps)
         compiled-deps    (!? deps (transpiler-make-code transpiler !))
         compiled-after   (target-transpile-2 after-deps)
         compiled-acctop  (target-transpile-accumulated-toplevels transpiler))
    (& *show-transpiler-progress?*
       (format t "; Phew!~%"))
    (!? compiled-deps
        (= (transpiler-imported-deps transpiler) (transpiler-concat-text transpiler imported-deps !)))
    (transpiler-concat-text transpiler
                            (!? prologue-gen (funcall !))
                            (!? decl-gen (funcall !))
                            compiled-before
                            (reverse (transpiler-raw-decls transpiler))
                            (transpiler-imported-deps transpiler)
                            compiled-after
                            compiled-acctop
                            (!? epilogue-gen (funcall !)))))

(def-transpiler transpile-0 (transpiler sections)
  (!? frontend-init (funcall !))
  (with (before-deps  (target-transpile-1 (!? sections-before-deps (funcall ! transpiler)))
         after-deps   (target-transpile-1 (+ (!? sections-after-deps (funcall ! transpiler))
                                             sections))
		 deps         (target-sighten-deps transpiler))
    (& *show-transpiler-progress?*
       (let num-exprs (apply #'+ (mapcar [length ._]
                                         (+ before-deps deps after-deps)))
         (format t "; ~A top level expressions.~%" num-exprs)))
    (transpile-codegen transpiler before-deps deps after-deps)))

(def-transpiler transpile-print-stats (transpiler start-time)
  (& print-obfuscations?
     obfuscate?
     (transpiler-print-obfuscations transpiler))
  (warn-unused-functions transpiler)
  (tell-number-of-warnings)
  (& *show-transpiler-progress?*
     (format t "; ~A seconds passed.~%~F" (integer (/ (- (nanotime) start-time) 1000000000)))))

(def-transpiler target-transpile (transpiler sections)
  (let start-time (nanotime)
    (= *warnings* nil)
    (with-temporaries (*recompiling?*  (& sections-to-update t)
                       *transpiler*    transpiler
                       *assert*        (| *assert* assert?))
      (& *have-compiler?*
         (= (transpiler-save-sources? transpiler) t))
      (& sections-to-update
         (clr (transpiler-emitted-decls transpiler)))
      (= (transpiler-host-functions-hash transpiler) (make-host-functions-hash))
      (= (transpiler-host-variables-hash transpiler) (make-host-variables-hash))
      (prog1
        (transpile-0 transpiler sections)
        (transpile-print-stats transpiler start-time)))))
