; tré – Copyright (c) 2008–2014 Sven Michael Klose <pixel@copei.de>

(defun compile-section? (section processed-sections)
  (| (member section (sections-to-update))
     (not (assoc section processed-sections))))

(defun accumulated-toplevel? (section)
  (not (eq 'accumulated-toplevel section)))

(defun map-section (x fun sections cached-sections)
  (with-cons section data x
    (with-temporaries ((current-section)       section
                       (current-section-data)  data)
      (. section (? (compile-section? section cached-sections)
                    (funcall fun section data)
                    (assoc-value section cached-sections))))))

(defun map-sections (fun sections cached-sections)
  (filter [map-section _ fun sections cached-sections]
          sections))

(defun development-message (fmt &rest args)
  (when *development?*
    (fresh-line)
    (princ "; ")
    (apply #'format t fmt args)))

(defun codegen-section (section data)
  (development-message "Middle-/backend ~A~%" section)
  (with-temporary (accumulate-toplevel-expressions?) (not (accumulated-toplevel? section))
    (backend (middleend data))))

(defun generic-compile-2 (sections)
  (alet (map-sections #'codegen-section
                      sections
                      (compiled-files))
    (= (compiled-files) !)
    (cdrlist !)))

(defun generic-load (path)
  (print-definition `(load ,path))
  (frontend (read-file path)))

(defun frontend-section (section data)
  (development-message "Frontend ~A~%" section)
  (?
    (symbol? section)  (frontend (? (function? data)
                                    (funcall data)
                                    data))
    (string? section)  (generic-load section)
    (error "Don't know what to do with section ~A." section)))

(defun generic-compile-1 (sections)
  (alet (map-sections #'frontend-section sections (frontend-files))
    (= (frontend-files) !)))

(defun quick-compile-sections (x)
  (backend (middleend (apply #'+ (cdrlist (generic-compile-1 X))))))

(defun make-toplevel-function ()
  `((defun accumulated-toplevel ()
      ,@(reverse (accumulated-toplevel-expressions)))))

(defun generic-compile-delayed-exprs ()
  (with-temporary (sections-to-update) '(delayed-exprs)
    (quick-compile-sections (list (. 'delayed-exprs
                                     (delayed-exprs))))))

(defun generic-compile-accumulated-toplevels ()
  (& (accumulate-toplevel-expressions?)
     (accumulated-toplevel-expressions)
     (with-temporary (sections-to-update) '(accumulated-toplevel)
       (quick-compile-sections (list (. 'accumulated-toplevel
                                        #'make-toplevel-function))))))

(defun tell-number-of-warnings ()
  (alet (length *warnings*)
    (fresh-line)
    (format t "; ~A warning~A.~%"
            (? (zero? !) "No" !)
            (? (== 1 !) "" "s"))))

(defun generic-codegen (before-deps deps after-deps)
  (print-status "Let me think. Hmm...~F")
  (!? (middleend-init)
      (funcall !))
  (with (compiled-before   (generic-compile-2 before-deps)
         compiled-deps     (backend (middleend deps))
         compiled-after    (generic-compile-2 after-deps)
         compiled-acctop   (generic-compile-accumulated-toplevels)
         compiled-delayed  (generic-compile-delayed-exprs))
    (!? compiled-deps
        (+! (imported-deps) compiled-deps))
    (transpiler-postprocess (!? (prologue-gen) (funcall !))
                            (!? (decl-gen) (funcall !))
                            compiled-before
                            (reverse (raw-decls))
                            (imported-deps)
                            compiled-after
                            compiled-acctop
                            compiled-delayed
                            (!? (epilogue-gen) (funcall !)))))

(defun section-data (x)
  (apply #'+ (cdrlist x)))

(defun generic-compile-0 (sections)
  (!? (frontend-init)
      (funcall !))
  (with (before-deps  (generic-compile-1 (!? (sections-before-deps) (funcall !)))
         after-deps   (generic-compile-1 (+ (!? (sections-after-deps) (funcall !))
                                            sections
                                            (!? (ending-sections) (funcall !))))
         deps         (import-from-environment))
   (generic-codegen before-deps deps after-deps)))

(defun print-transpiler-stats (start-time)
  (& (obfuscate?)
     (print-obfuscations?)
     (print-obfuscations))
  (warn-unused-functions)
  (tell-number-of-warnings)
  (print-status "~A seconds passed.~%~F"
                (integer (/ (- (nanotime) start-time) 1000000000))))

(defun generic-compile (tr sections)
  (let start-time (nanotime)
    (= *warnings* nil)
    (with-temporaries (*transpiler*    tr
                       *recompiling?*  (& (sections-to-update) t)
                       *assert*        (| *assert* (assert?)))
      (& (sections-to-update)
         (clr (emitted-decls)))
      (= (host-functions) (make-host-functions))
      (= (host-variables) (make-host-variables))
      (prog1
        (generic-compile-0 sections)
        (print-transpiler-stats start-time)
        (print-status "Phew!~%")))))
