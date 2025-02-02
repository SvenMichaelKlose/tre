(fn make-project (&key name sections transpiler (emitter nil))
  (format t "; Making project '~A'…~%" name)
  (let code (compile-sections :sections (ensure-list sections)
                              :transpiler transpiler)
    (!? emitter
        (~> ! code))
    code))
