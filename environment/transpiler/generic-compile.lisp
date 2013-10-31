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

(defun compile-without-frontend (x)
  (backend (middleend x)))

(defun quick-generic-compile (x)
  (backend (middleend (frontend x))))

(defun map-transpiler-sections (fun sections cached-sections)
  (with (tr       *transpiler*
         results  nil)
	(dolist (i sections (reverse results))
      (with-cons section data i
        (with-temporaries ((transpiler-current-section tr)       section
                           (transpiler-current-section-data tr)  data)
          (acons! section 
                  (? (compile-section? section cached-sections)
                     (funcall fun section data)
                     (assoc-value section cached-sections :test #'eq|string==))
                  results))))))

(defun codegen-section (section data)
  (with-temporary (transpiler-accumulate-toplevel-expressions? *transpiler*) (not (accumulated-toplevel? section))
    (compile-without-frontend data)))

(defun generic-compile-2 (sections)
  (alet (map-transpiler-sections #'codegen-section sections (transpiler-compiled-files *transpiler*))
    (= (transpiler-compiled-files *transpiler*) !)
    (cdrlist !)))

(defun generic-load (path)
  (format t "(LOAD \"~A\")~%" path)
  (force-output)
  (frontend (read-file-all path)))

(defun frontend-section (section data)
  (?
    (symbol? section)  (frontend (? (function? data)
                                    (funcall data)
                                    data))
    (string? section)  (generic-load section)
    (error "Don't know what to do with section ~A." section)))

(defun generic-compile-1 (sections)
  (alet (map-transpiler-sections #'frontend-section sections (transpiler-frontend-files *transpiler*))
    (= (transpiler-frontend-files *transpiler*) !)))

(defun make-toplevel-function ()
  `((defun accumulated-toplevel ()
      ,@(reverse (transpiler-accumulated-toplevel-expressions *transpiler*)))))

(defun generic-compile-accumulated-toplevels ()
  (alet *transpiler*
    (& (transpiler-accumulate-toplevel-expressions? !)
       (transpiler-accumulated-toplevel-expressions !)
       (with-temporary (transpiler-sections-to-update !) '(accumulated-toplevel)
	     (compile-without-frontend (generic-compile-1 (list (. 'accumulated-toplevel
                                                            #'make-toplevel-function))))))))

(defun tell-number-of-warnings ()
  (alet (length *warnings*)
    (format t "; ~A warning~A.~%"
            (? (zero? !) "No" !)
            (? (== 1 !) "" "s"))))

(def-transpiler generic-codegen (transpiler before-deps deps after-deps)
  (& *show-transpiler-progress?*
     (format t "; Let me think. Hmm...~%"))
  (!? middleend-init (funcall !))
  (with (compiled-before  (generic-compile-2 before-deps)
         compiled-deps    (!? deps (compile-without-frontend !))
         compiled-after   (generic-compile-2 after-deps)
         compiled-acctop  (generic-compile-accumulated-toplevels))
    (& *show-transpiler-progress?*
       (format t "; Phew!~%"))
    (!? compiled-deps
        (= (transpiler-imported-deps transpiler) (transpiler-concat-text imported-deps !)))
    (transpiler-concat-text (!? prologue-gen (funcall !))
                            (!? decl-gen (funcall !))
                            compiled-before
                            (reverse (transpiler-raw-decls transpiler))
                            (transpiler-imported-deps transpiler)
                            compiled-after
                            compiled-acctop
                            (!? epilogue-gen (funcall !)))))

(defun generic-import (tr)
  (with-temporary (transpiler-save-argument-defs-only? tr) nil
    (transpiler-import-from-environment tr)))

(def-transpiler generic-compile-0 (transpiler sections)
  (!? frontend-init (funcall !))
  (with (before-deps  (generic-compile-1 (!? sections-before-deps (funcall ! transpiler)))
         after-deps   (generic-compile-1 (+ (!? sections-after-deps (funcall ! transpiler))
                                            sections))
		 deps         (generic-import transpiler))
    (generic-codegen transpiler before-deps deps after-deps)))

(def-transpiler print-transpiler-stats (transpiler start-time)
  (& print-obfuscations?
     obfuscate?
     (transpiler-print-obfuscations transpiler))
  (warn-unused-functions transpiler)
  (tell-number-of-warnings)
  (& *show-transpiler-progress?*
     (format t "; ~A seconds passed.~%~F" (integer (/ (- (nanotime) start-time) 1000000000)))))

(def-transpiler generic-compile (transpiler sections)
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
        (generic-compile-0 transpiler sections)
        (print-transpiler-stats transpiler start-time)))))