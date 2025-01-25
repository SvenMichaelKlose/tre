(fn quick-compile (x)
  (backend (middleend (frontend x))))

(fn map-sections (fun sections)
  (@ [. _. (~> fun _. ._)] sections))

(fn codegen-section (section data)
  (developer-note "Compiling ~A…~%" section)
  (backend (middleend data)))

(fn codegen-sections (sections)
  (*> #'+ (cdrlist (map-sections #'codegen-section sections))))

(fn quick-compile-sections (x)
  (codegen-sections (frontend-sections x)))

(fn codegen-accumulated-toplevels ()
  (awhen (& (enabled-pass? :accumulate-toplevel)
            (accumulated-toplevel-expressions))
    (developer-note "Compiling accumulated top–level expressions…~%")
    (with-temporaries ((sections-to-update) '(:accumulated-toplevel)
                       (disabled-passes)    (. :accumulate-toplevel
                                               (disabled-passes)))
      (quick-compile-sections
          (… (. :accumulated-toplevel
                (reverse !)))))))

(fn compile-delayed-exprs ()
  (developer-note "Compiling delayed expressions…~%")
  (with-temporary (sections-to-update) '(:delayed-exprs)
    (quick-compile-sections
        (… (. :delayed-exprs
              (delayed-exprs))))))

(fn compile-imports (imports)
  (developer-note "Compiling imports…~%")
  (backend (middleend imports)))

(fn compile-inits ()
  (developer-note "Compiling inits…~%")
  (quick-compile-sections
      (… (. :compiled-inits
            (reverse (compiled-inits))))))

(fn generic-codegen (&key before-import after-import imports)
  (print-status "Let me think. Hmm…~F")
  (~> (middleend-init))
  (with (before-imports
           (codegen-sections before-import)
         imports-and-rest
           (+ (compile-imports imports)
              (compile-delayed-exprs)
              (codegen-sections after-import)
              (codegen-accumulated-toplevels)))
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
  (with-temporary *package* *package*
    (map-sections #'frontend-section sections)))

(fn tell-number-of-warnings ()
  (!= (length *warnings*)
    (format t "~L; ~A warning~A.~%"
              (? (== 0 !) "No" !)
              (? (== 1 !) "" "s"))))

(fn seconds-passed (start-time)
  (/ (- (milliseconds-since-1970) start-time) 1000))

(fn print-transpiler-stats (start-time)
  ;(warn-unused-functions)
  (tell-number-of-warnings)
  (print-status "~A seconds passed.~%"
                (integer (seconds-passed start-time))))

(fn expand-sections (sections)
  (@ [? (string? _)
        (… _)
        _]
     sections))

(fn compile-sections (sections &key (transpiler *default-transpiler*))
  (let start-time (milliseconds-since-1970)
    (= *warnings* nil)
    (with-temporaries (*transpiler*  transpiler
                       *assert?*     (| *assert?* (assert?)))
      (= (host-functions) (make-host-functions))
      (= (host-variables) (make-host-variables))
      (~> (frontend-init))
      (prog1 (generic-codegen
                 :before-import
                   (frontend-sections (~> (sections-before-import)))
                 :after-import
                   (+ (frontend-sections (~> (sections-after-import)))
                      (frontend-sections (expand-sections sections)))
                 :imports
                   (+ (… "Section imports")
                      (with-temporary *package* *package*
                        (import-from-host))))
        (print-transpiler-stats start-time)
        (print-status "Phew!~%")))))

(fn compile (expression &key (transpiler *default-transpiler*))
  (compile-sections :sections   `((t ,expression))
                    :transpiler transpiler))
