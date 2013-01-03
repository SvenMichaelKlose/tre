;;;;; tré – Copyright (c) 2008–2013 Sven Michael Klose <pixel@copei.de>

(defun compile-0 (sources &key (target nil) (transpiler nil) (obfuscate? nil) (print-obfuscations? nil) (files-to-update nil))
  (| target (error "target missing"))
  (funcall (case target
             'c ,(& *have-c-compiler?* '#'c-transpile)
             'bytecode ,(& *have-c-compiler?* '#'bc-transpile)
             'js #'js-transpile
             'php #'php-transpile
             (error "unknown target ~A"))
           sources
           :transpiler (| transpiler
                          (copy-transpiler
                            (case target
                              'c ,(& *have-c-compiler?* '*c-transpiler*)
                              'bytecode ,(& *have-c-compiler? '*bc-transpiler*)
                              'js *js-transpiler*
                              'php *php-transpiler*)))
           :obfuscate? obfuscate?
           :print-obfuscations? print-obfuscations?
           :files-to-update files-to-update))

(defun compile-files (files &key (target nil) (transpiler nil) (obfuscate? nil) (print-obfuscations? nil) (files-to-update nil))
  (compile-0 (mapcar #'list files)
             :target target :transpiler transpiler :obfuscate? obfuscate? :print-obfuscations? print-obfuscations? :files-to-update files-to-update))

(defun compile-sections (sections &key (target nil) (transpiler nil) (obfuscate? nil) (print-obfuscations? nil) (files-to-update nil) (section-id 'compile))
  (compile-0 sections
             :target target :transpiler transpiler :obfuscate? obfuscate? :print-obfuscations? print-obfuscations? :files-to-update files-to-update))

(defun compile (expression &key (target nil) (transpiler nil) (obfuscate? nil) (print-obfuscations? nil) (files-to-update nil) (section-id 'compile))
  (compile-0 (& expression `((,section-id . (,expression))))
             :target target :transpiler transpiler :obfuscate? obfuscate? :print-obfuscations? print-obfuscations? :files-to-update files-to-update))

(defun compile-c-environment (funs)
  (let transpiler (copy-transpiler *c-transpiler*)
    (transpiler-add-wanted-functions transpiler funs)
    (let code (compile-files nil :target 'c :transpiler transpiler)
      (with-open-file out (open "interpreter/_compiled-env.c" :direction 'output)
	    (princ code out))))
  nil)

(defun compile-bytecode-environment (funs)
  (let transpiler (copy-transpiler *bc-transpiler*)
    (transpiler-add-wanted-functions transpiler funs)
    (compile-files nil :target 'bytecode :transpiler transpiler))
  nil)
