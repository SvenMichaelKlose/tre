(defun make-project (project-name sections &key transpiler
                                                (section-list-gen      nil)
                                                (sections-to-update    nil)
                                                (recompiler-path       nil)
                                                (emitter               nil)
                                                (obfuscate?            nil))
  (format t "; Making project '~A'...~%" project-name)
  (= (transpiler-sections-to-update transpiler) sections-to-update)
  (& obfuscate?
     (transpiler-enable-pass transpiler :obfuscate))
  (let code (compile-sections sections :transpiler transpiler)
    (!? emitter
        (funcall ! code))
    (awhen recompiler-path
      (| section-list-gen
         (error (+ "The recompiler requires argument SECTION-LIST-GEN which is a function "
                   "without arguments that returns a list of names of modified sections.")))
      (format t "; Making recompiler '~A'...~F" recompiler-path)
      (sys-image-create recompiler-path
                        [0 (make-project project-name sections
                                         :transpiler          transpiler
                                         :section-list-gen    section-list-gen
                                         :sections-to-update  (funcall section-list-gen)
                                         :recompiler-path     recompiler-path
                                         :emitter             emitter
                                         :obfuscate?          obfuscate?)
                           (quit)])
      (format t " OK.~%"))
    code))
