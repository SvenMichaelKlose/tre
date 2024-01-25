(fn make-project (project-name sections &key transpiler (emitter nil))
  (format t "; Making project '~A'…~%" project-name)
  (= sections (ensure-list sections))
  (let code (compile-sections sections :transpiler transpiler)
    (!? emitter
        (~> ! code))
    code))
