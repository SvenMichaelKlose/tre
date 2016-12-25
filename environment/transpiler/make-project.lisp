(defun make-project (project-name sections &key transpiler
                                                (modified-file-getter  nil)
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
      (| modified-file-getter
         (error (+ "The recompiler requires argument MODIFIED-FILE-GETTER which is a function "
                   "without arguments returning a list of modified sections.")))
      ; TODO: Rename MODIFIED-FILE-GETTER to GEN-FILELIST.
      (format t "; Making recompiler '~A'...~F" recompiler-path)
      (= *allow-redefinitions?* t)
      (sys-image-create recompiler-path
                        #'(()
                             (make-project project-name sections
                                           :transpiler            transpiler
                                           :modified-file-getter  modified-file-getter
                                           :sections-to-update    (funcall modified-file-getter)
                                           :recompiler-path       recompiler-path
                                           :emitter               emitter
                                           :obfuscate?            obfuscate?)
                             (quit)))
      (format t " OK.~%"))
    code))
