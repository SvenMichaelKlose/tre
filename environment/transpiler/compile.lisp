(fn full-compile (x)
  (backend (middleend (frontend x))))

(fn map-sections (fun sections)
  (@ [. _. (~> fun _. ._)] sections))

(fn codegen-section (section data)
  (developer-note "Compiling ~A…~%" section)
  (backend (middleend data)))

(fn codegen-sections (sections)
  (*> #'+ (cdrlist (map-sections #'codegen-section sections))))

(fn full-compile-section (section x)
  (codegen-sections (frontend-sections (… (. section x)))))


;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; DEDICATED SECTIONS ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;

(fn compile-toplevel-expressions ()
  (awhen (& (enabled-pass? :accumulate-toplevel)
            (toplevel-expressions))
    (with-temporaries ((sections-to-update)
                         '(:accumulated-toplevel)
                       (disabled-passes)
                         (. :accumulate-toplevel (disabled-passes)))
      (full-compile-section :accumulated-toplevel (reverse !)))))

(fn compile-delayed-exprs ()
  (with-temporary (sections-to-update) '(:delayed-exprs)
    (full-compile-section :delayed-exprs (delayed-exprs))))

(fn compile-inits ()
  (full-compile-section :compiled-inits (reverse (compiled-inits))))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; SECTION ORCHESTRATION ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(fn generic-codegen (&key before-import after-import imports)
  (print-status "Let me think. Hmm…~F")
  (~> (callback-after-frontend))
  (~> (middleend-init))
  (with (before-imports
           (codegen-sections before-import)
         imports-and-rest
           (+ (codegen-section :imports imports)
              (compile-delayed-exprs)
              (codegen-sections after-import)
              (compile-toplevel-expressions)))
    (~> (postprocessor)
        (+ (… (~> (prologue-gen)))
           before-imports
           (compile-inits)
           imports-and-rest
           (… (~> (epilogue-gen)))))))

(fn frontend-section (section x)
  (developer-note "Frontend ~A~%" section)
  (+@ [frontend (… _)]
      (+ `((%comment "Section " ,(? (symbol? section)
                                    (symbol-name section)
                                    section)))
         (pcase section
           symbol?
             (? (function? x)
                (~> x)
                x)
           string?
             (with-temporary *load* section
               (format t "; Loading \"~A\"…~%" section)
               (read-file section))
           (error "Alien section")))))

(fn frontend-sections (sections)
  (map-sections #'frontend-section sections))

;;;;;;;;;;;;;;;
;;; TOPLEVEL;;;
;;;;;;;;;;;;;;;

(define-filter expand-sections (section)
  (? (string? section)
     (… section)
     section))

(fn compile-sections (&key sections (transpiler *default-transpiler*))
    (= *warnings* nil)
    (with-temporaries (*transpiler*  transpiler
                       *assert?*     (| *assert?* (assert?)))
      (= (host-functions) (make-host-functions))
      (= (host-variables) (make-host-variables))
      (~> (frontend-init))
      (generic-codegen
           :before-import
             (frontend-sections (~> (sections-before-import)))
           :after-import
             (+ (frontend-sections (~> (sections-after-import)))
                (frontend-sections (expand-sections sections)))
           :imports
             (+ (… "Section imports")
                (import-from-host)))))

(fn compile (expression &key (transpiler *default-transpiler*))
  (compile-sections :sections   `((t ,expression))
                    :transpiler transpiler))
