(fn seconds-passed (start-time)
  (/ (- (milliseconds-since-1970) start-time) 1000))


(fn tell-number-of-warnings ()
  (!= (length *warnings*)
    (format t "~L; ~A warning~A.~%"
              (? (== 0 !) "No" !)
              (? (== 1 !) "" "s"))))

(fn print-passed-seconds (start-time)
  ;(warn-unused-functions)
  (tell-number-of-warnings)
  (print-status "~A seconds passed.~%"
                (integer (seconds-passed start-time))))

(fn make-project (&key name sections transpiler (emitter nil))
  (format t "; Making ~A project '~A'…~%"
          (transpiler-name transpiler) name)
  (with (start-time (milliseconds-since-1970)
         code       (compile-sections :sections (ensure-list sections)
                                      :transpiler transpiler))
    (!? emitter (~> ! code)
    (print-passed-seconds start-time)
    (print-status "Phew!~%")
    code)))

(fn warn-unused-functions ()
  (!= (defined-functions)
    (@ [hremove ! _]
       (+ (hashkeys (used-functions))
          (hashkeys (expander-macros (transpiler-macro-expander)))
          (hashkeys (expander-macros (codegen-expander)))
          *macros*))
    (!? (+@ [!= (symbol-name _)
              (& (not (tail? ! "_TREEXP")
                      (head? ! "~"))
                 (_ !))]
           (hashkeys !))
      (warn "Unused functions: ~A." (late-print ! nil)))))
