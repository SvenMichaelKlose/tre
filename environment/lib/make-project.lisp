;;;;; tré – Copyright (c) 2008–2013 Sven Michael Klose <pixel@copei.de>

(defun make-project (project-name &key target
                                       (files nil)
                                       (modified-file-getter nil)
                                       (files-to-update nil)
                                       (recompiler-path nil)
                                       (emitter nil)
                                       (obfuscate? nil))
  (format t "; Making project '~A'...~%" project-name)
  (| (in? target 'c 'bytecode 'js 'php)
     (error "You must specify a target. It must be one of C, BYTECODE, JS or PHP."))
  (| emitter
     (error "Argument EMITTER is required, which takes the compiled code and puts it somewhere."))
  (let code (compile-files files :target target :files-to-update files-to-update :obfuscate? obfuscate?)
    (funcall emitter code)
    (awhen recompiler-path
      (| modified-file-getter
         (error "The recompiler requires argument MODIFIED-FILE-GETTER: a function without arguments which returns a list of modified files."))
      (format t "; Making recompiler '~A'...~F" recompiler-path)
      (= *allow-redefinitions?* t)
      (sys-image-create recompiler-path
                        #'(()
                             (make-project project-name
                                           :target target
                                           :files files
                                           :modified-file-getter modified-file-getter
                                           :files-to-update (funcall modified-file-getter)
                                           :recompiler-path recompiler-path
                                           :emitter emitter
                                           :obfuscate? obfuscate?)
                             (quit)))
      (format t " OK.~%"))))
