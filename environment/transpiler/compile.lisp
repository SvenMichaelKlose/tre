(fn map-section (fun x)
  (with-cons section data x
    (. section (~> fun section data))))

(fn map-sections (fun sections)
  (@ [map-section fun _] sections))

(fn codegen (x)
  (backend (middleend x)))

(fn codegen-section (section data)
  (developer-note "Codegen ~A…~%" section)
  (codegen data))

(fn codegen-sections (sections)
  (*> #'+ (cdrlist (map-sections #'codegen-section sections))))

(fn quick-compile (x)
  (codegen (frontend x)))

(fn quick-compile-sections (x)
  (codegen-sections (frontend-sections x)))

(fn gen-toplevel-function ()
  `((fn accumulated-toplevel ()
      ,@(reverse (accumulated-toplevel-expressions)))))

(fn codegen-accumulated-toplevels ()
  (& (enabled-pass? :accumulate-toplevel)
     (accumulated-toplevel-expressions)
     (with-temporaries ((sections-to-update) '(:accumulated-toplevel)
                        (disabled-passes)    (. :accumulate-toplevel
                                                (disabled-passes)))
       (developer-note "Making top–level expressions…~%")
       (quick-compile-sections (… (. :accumulated-toplevel
                                     #'gen-toplevel-function))))))

(fn compile-delayed-exprs ()
  (developer-note "Making delayed expressions…~%")
  (with-temporary (sections-to-update) '(:delayed-exprs)
    (quick-compile-sections (… (. :delayed-exprs (delayed-exprs))))))

(fn generic-codegen (before-import after-import imports)
  (print-status "Let me think. Hmm…~F")
  (~> (middleend-init))
  (with (before-imports
          (codegen-sections before-import)
         imports-and-rest
          (+ (progn
               (developer-note "Making imports…~%")
               (codegen imports))
             (compile-delayed-exprs)
             (codegen-sections after-import)
             (codegen-accumulated-toplevels)))
    (~> (postprocessor)
        (+ (… (~> (prologue-gen)))
           before-imports
           (quick-compile-sections (… (. :compiled-inits
                                         (reverse (compiled-inits)))))
           imports-and-rest
           (… (~> (epilogue-gen)))))))

(fn frontend-section-load (path)
  (format t "; Loading \"~A\"…~%" path)
  (with-temporary *load* path
    (read-file path)))

(fn section-comment (section)
  `((%comment "Section " ,(? (symbol? section)
                             (symbol-name section)
                             section))))

(fn frontend-section (section x)
  (developer-note "Frontend ~A.~%" section)
  (+@ [frontend (… _)]
      (+ (section-comment section)
         (pcase section
           symbol?  (? (function? x)
                       (~> x)
                       x)
           string?  (frontend-section-load section)
           (error "Alien section ~A." section)))))

(fn frontend-sections (sections)
  (with-temporary *package* *package*
    (map-sections #'frontend-section sections)))

(fn generic-frontend (sections)
  (~> (frontend-init))
  (generic-codegen (frontend-sections (~> (sections-before-import)))
                   (+ (frontend-sections (~> (sections-after-import)))
                      (frontend-sections sections))
                   (+ (… "Section imports")
                      (with-temporary *package* *package*
                        (import-from-host)))))

(fn tell-number-of-warnings ()
  (!= (length *warnings*)
    (format t "~L; ~A warning~A.~%"
              (? (== 0 !) "No" !)
              (? (== 1 !) "" "s"))))

(fn seconds-passed (start-time)
  (/ (- (milliseconds-since-1970) start-time) 1000))

(fn print-transpiler-stats (start-time)
  (warn-unused-functions)
  (tell-number-of-warnings)
  (print-status "~A seconds passed.~%" (integer (seconds-passed start-time))))

(fn compile-sections (sections &key (transpiler nil))
  (let start-time (milliseconds-since-1970)
    (= *warnings* nil)
    (with-temporaries (*transpiler*  (| transpiler
                                        (copy-transpiler *default-transpiler*))
                       *assert?*     (| *assert?* (assert?)))
      (= (host-functions) (make-host-functions))
      (= (host-variables) (make-host-variables))
      (prog1 (generic-frontend (@ [? (string? _) (… _) _] sections))
        (print-transpiler-stats start-time)
        (print-status "Phew!~%")))))

(fn compile (expression &key (transpiler nil))
  (compile-sections `((t ,expression)) :transpiler transpiler))
