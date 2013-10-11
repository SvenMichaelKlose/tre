;;;;; tré – Copyright (c) 2008–2013 Sven Michael Klose <pixel@copei.de>

(defun make-project (project-name sections
                     &key transpiler
                          (modified-file-getter  nil)
                          (sections-to-update    nil)
                          (recompiler-path       nil)
                          (emitter               nil)
                          (obfuscate?            nil))
  (format t "; Making project '~A'...~%" project-name)
  (| emitter
     (error "Argument EMITTER is required, which takes the compiled code and puts it somewhere."))
  (= (transpiler-sections-to-update transpiler) sections-to-update)
  (= (transpiler-obfuscate? transpiler) obfuscate?)
  (let code (compile-sections sections :transpiler transpiler)
    (funcall emitter code)
    (awhen recompiler-path
      (| modified-file-getter
         (error "The recompiler requires argument MODIFIED-FILE-GETTER: a function without arguments which returns a list of modified sections."))
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
      (format t " OK.~%"))))
