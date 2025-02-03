(fn seconds-passed (start-time)
  (/ (- (milliseconds-since-1970) start-time) 1000))

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
