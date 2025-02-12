(fn full-compile (x)
  (backend (middleend (frontend x))))

(define-filter expand-sections (section)
  (?
    (string? section)
      (… section)
    (& (cons? section)
       (function? .section))
      (. section. (~> .section))
    section))

(fn map-sections (fun sections)
  "Filter tails of SECTIONS through FUN."
  (!= (expand-sections sections)
    (@ [. _. (~> fun _. ._)]
       (? nil; *development?*
          (+@ #'((x)
                  (with (section  x.
                         exprs    .x)
                    (@ [… section _] exprs)))
              !)
          !))))

(fn codegen-section (section data)
  (backend (middleend data)))

(fn codegen-sections (sections)
  (*> #'+ (cdrlist (map-sections #'codegen-section sections))))

(fn frontend-section (section x)
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

(fn full-compile-section (section x)
  (codegen-section section (frontend-section section x)))


;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; DEDICATED SECTIONS ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;

(fn compile-toplevel-expressions ()
  (awhen (& (enabled-pass? :accumulate-toplevel)
            (toplevel-expressions))
    (full-compile-section 'accumulated-toplevel (reverse !))))

(fn compile-delayed-exprs ()
  (full-compile-section 'delayed-exprs (delayed-exprs)))

(fn compile-inits ()
  (full-compile-section 'global-inits (reverse (global-inits))))


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
           (+ (codegen-section 'imports imports)
              (compile-delayed-exprs)
              (codegen-sections after-import)
              (compile-toplevel-expressions)))
    (~> (postprocessor)
        (+ (… (~> (prologue)))
           before-imports
           (compile-inits)
           imports-and-rest
           (… (~> (epilogue)))))))


;;;;;;;;;;;;;;;
;;; TOPLEVEL;;;
;;;;;;;;;;;;;;;

(fn compile-sections (&key sections (transpiler *default-transpiler*))
    (= *warnings* nil)
    (with-temporaries (*transpiler* transpiler
                       *assert?*    (| *assert?* (assert?)))
      (= (host-functions) (make-host-functions))
      (= (host-variables) (make-host-variables))
      (~> (frontend-init))
      (generic-codegen
          :before-import
            (frontend-sections (~> (sections-before-import)))
          :after-import
            (+ (frontend-sections (~> (sections-after-import)))
               (frontend-sections sections))
          :imports
            (frontend-section 'imports (import-from-host)))))

(fn compile (expression &key (transpiler *default-transpiler*))
  (compile-sections :sections   `((:compile ,expression))
                    :transpiler transpiler))
