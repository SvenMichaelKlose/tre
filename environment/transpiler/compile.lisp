(fn update-section? (section cached-sections)
  (| (member section (sections-to-update))
     (not (assoc section cached-sections))))

(fn map-section (x fun sections cached-sections)
  (with-cons section data x
    (with-temporaries ((current-section)       section
                       (current-section-data)  data)
      (. section
         (? (update-section? section cached-sections)
            (funcall fun section data)
            (assoc-value section cached-sections))))))

(fn map-sections (fun sections cached-sections)
  (@ [map-section _ fun sections cached-sections]
     sections))

(fn codegen (x)
  (backend (middleend x)))

(fn codegen-section (section data)
  (developer-note "Processing section ~A…~%" section)
  (apply #'+ (remove-if #'not (codegen data))))

(fn codegen-sections (sections)
  (alet (map-sections #'codegen-section sections (cached-output-sections))
    (= (cached-output-sections) !)
    (@ #'cdr !)))

(fn quick-compile-sections (x)
  (codegen-sections (frontend-sections x)))

(fn gen-toplevel-function ()
  `((fn accumulated-toplevel ()
      ,@(reverse (accumulated-toplevel-expressions)))))

(fn codegen-delayed-exprs ()
  (developer-note "Generating delayed expressions…~%")
  (with-temporary (sections-to-update) '(delayed-exprs)
    (quick-compile-sections (list (. 'delayed-exprs
                                     (apply #'append (delayed-exprs)))))))

(fn codegen-accumulated-toplevels ()
  (& (enabled-pass? :accumulate-toplevel)
     (accumulated-toplevel-expressions)
     (with-temporaries ((sections-to-update) '(accumulated-toplevel))
       (developer-note "Generating top–level expressions…~%")
       (push :accumulate-toplevel (disabled-passes))
       (prog1
         (quick-compile-sections (list (. 'accumulated-toplevel
                                          #'gen-toplevel-function)))
         (pop (disabled-passes))))))

(fn dechunk (x)
  (remove-if #'not (apply #'append x)))

(fn generic-codegen (before-import after-import imports)
  (print-status "Let me think. Hmm...~F")
  (funcall (middleend-init))
  (with (before-imports    (codegen-sections before-import)
         imports-and-rest  (append {(developer-note "Generating imports…~%")
                                    (codegen (@ #'list imports))}
                                   (codegen-delayed-exprs)
                                   (codegen-sections after-import)
                                   (codegen-accumulated-toplevels)))
    (funcall (postprocessor) (append (!? (funcall (prologue-gen))
                                         (list !))
                                     (dechunk (append (funcall (decl-gen))
                                                      before-imports
                                                     (reverse (raw-decls))
                                                     imports-and-rest))
                                     (!? (funcall (epilogue-gen))
                                         (list !))))))

(fn frontend-section-load (path)
  (print-definition `(load ,path))
  (load-file path))

(fn section-comment (section)
  `((%%comment "Section " ,(? (symbol? section)
                              (symbol-name section)
                              section))))

(fn frontend-section (section data)
  (developer-note "Frontend ~A.~%" section)
  (frontend (@ #'list
               (+ (section-comment section)
                  (pcase section
                    symbol?  (? (function? data)
                                (funcall data)
                                data)
                    string?  (frontend-section-load section)
                    (error "Don't know what to do with section ~A." section))))))

(fn frontend-sections (sections)
  (alet (map-sections #'frontend-section sections (cached-frontend-sections))
    (= (cached-frontend-sections) !)))

(fn generic-frontend (sections)
  (funcall (frontend-init))
  (generic-codegen (frontend-sections (funcall (sections-before-import)))
                   (frontend-sections (+ (funcall (sections-after-import))
                                         sections
                                         (funcall (ending-sections))))
                   (import-from-host)))

(fn tell-number-of-warnings ()
  (alet (length *warnings*)
    (format t "~L; ~A warning~A.~%"
              (? (zero? !) "No" !)
              (? (== 1 !) "" "s"))))

(fn print-transpiler-stats (start-time)
  (& (obfuscate?)
     (print-obfuscations?)
     (print-obfuscations))
  ;(warn-unused-functions)
  (tell-number-of-warnings)
  (print-status "~A seconds passed.~%"
                (integer (/ (- (nanotime) start-time) 1000000000))))

(fn compile-sections (sections &key (transpiler nil))
  (let start-time (nanotime)
    (= *warnings* nil)
    (with-temporaries (*transpiler*  (| transpiler
                                        (copy-transpiler *default-transpiler*))
                       *assert?*     (| *assert?* (assert?)))
      (& (sections-to-update)
         (clr (emitted-decls)))
      (= (host-functions) (make-host-functions))
      (= (host-variables) (make-host-variables))
      (prog1 (generic-frontend (@ [? (string? _) (list _) _]  sections))
        (print-transpiler-stats start-time)
        (print-status "Phew!~%")))))

(fn compile (expression &key (transpiler nil))
  (compile-sections `((t ,expression)) :transpiler transpiler))
