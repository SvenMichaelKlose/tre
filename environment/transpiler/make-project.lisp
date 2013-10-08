;;;;; tré – Copyright (c) 2008–2013 Sven Michael Klose <pixel@copei.de>

(defun make-project (project-name &key transpiler
                                       (files                 nil)
                                       (modified-file-getter  nil)
                                       (files-to-update       nil)
                                       (recompiler-path       nil)
                                       (emitter               nil)
                                       (obfuscate?            nil))
  (format t "; Making project '~A'...~%" project-name)
  (| emitter
     (error "Argument EMITTER is required, which takes the compiled code and puts it somewhere."))
  (= (transpiler-sections-to-update transpiler) files-to-update)
  (= (transpiler-obfuscate? transpiler) obfuscate?)
  (let code (compile-sections files :transpiler transpiler)
    (funcall emitter code)
    (awhen recompiler-path
      (| modified-file-getter
         (error "The recompiler requires argument MODIFIED-FILE-GETTER: a function without arguments which returns a list of modified files."))
      (format t "; Making recompiler '~A'...~F" recompiler-path)
      (= *allow-redefinitions?* t)
      (sys-image-create recompiler-path
                        #'(()
                             (make-project project-name
                                           :transpiler            transpiler
                                           :files                 files
                                           :modified-file-getter  modified-file-getter
                                           :files-to-update       (funcall modified-file-getter)
                                           :recompiler-path       recompiler-path
                                           :emitter               emitter
                                           :obfuscate?            obfuscate?)
                             (quit)))
      (format t " OK.~%"))))
