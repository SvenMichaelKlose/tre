(fn update-section? (section cached-sections)
  (| (member section (sections-to-update))
     (not (assoc section cached-sections))))

(fn map-section (x fun sections cached-sections)
  (with-cons section data x
    (. section
       (? (update-section? section cached-sections)
          (funcall fun section data)
          (assoc-value section cached-sections)))))

(fn map-sections (fun sections cached-sections)
  (@ [map-section _ fun sections cached-sections]
     sections))

(fn codegen (x)
  (backend (middleend x)))

(fn codegen-section (section data)
  (developer-note "Codegen ~A…~%" section)
  (codegen data))

(fn codegen-sections (sections)
  (!= (map-sections #'codegen-section sections (cached-output-sections))
    (= (cached-output-sections) !)
    (apply #'+ (@ #'cdr !))))

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
       (quick-compile-sections (list (. :accumulated-toplevel
                                        #'gen-toplevel-function))))))

(fn compile-delayed-exprs ()
  (developer-note "Making delayed expressions…~%")
  (with-temporary (sections-to-update) '(:delayed-exprs)
    (quick-compile-sections (list (. :delayed-exprs (delayed-exprs))))))

(fn generic-codegen (before-import after-import imports)
  (print-status "Let me think. Hmm…~F")
  (funcall (middleend-init))
  (with (before-imports
            (codegen-sections before-import)
         imports-and-rest
            (+ (progn
                 (developer-note "Making imports…~%")
                 (codegen imports))
               (compile-delayed-exprs)
               (codegen-sections after-import)
               (codegen-accumulated-toplevels)))
    (funcall (postprocessor)
             (+ (list (funcall (prologue-gen)))
                before-imports
                (quick-compile-sections (list (. :compiled-inits
                                                 (reverse (compiled-inits)))))
                imports-and-rest
                (list (funcall (epilogue-gen)))))))

(fn frontend-section-load (path)
  (format t "; Loading \"~A\"…~%" path)
  (read-file path))

(fn section-comment (section)
  `((%%comment "Section " ,(? (symbol? section)
                              (symbol-name section)
                              section))))

(fn frontend-section (section x)
  (developer-note "Frontend ~A.~%" section)
  (apply #'+ (@ [frontend (list _)]
                (+ (section-comment section)
                   (pcase section
                     symbol?  (? (function? x)
                                 (funcall x)
                                 x)
                     string?  (frontend-section-load section)
                     (error "Alien section ~A." section))))))

(fn frontend-sections (sections)
  (with-temporary *package* *package*
    (!= (map-sections #'frontend-section sections (cached-frontend-sections))
      (= (cached-frontend-sections) !))))

(fn generic-frontend (sections)
  (funcall (frontend-init))
  (generic-codegen (frontend-sections (funcall (sections-before-import)))
                   (+ (frontend-sections (funcall (sections-after-import)))
                      (frontend-sections sections))
                   (+ (list "Section imports")
                      (with-temporary *package* *package*
                        (import-from-host)))))

(fn tell-number-of-warnings ()
  (!= (length *warnings*)
    (format t "~L; ~A warning~A.~%"
              (? (zero? !) "No" !)
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
      (prog1 (generic-frontend (@ [? (string? _) (list _) _] sections))
        (print-transpiler-stats start-time)
        (print-status "Phew!~%")))))

(fn compile (expression &key (transpiler nil))
  (compile-sections `((t ,expression)) :transpiler transpiler))
