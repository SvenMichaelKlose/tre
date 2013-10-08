;;;;; tré – Copyright (c) 2008–2013 Sven Michael Klose <pixel@copei.de>

(defun compile-0 (sources &key target transpiler obfuscate? print-obfuscations? files-to-update)
  (| target (error "target missing"))
  (funcall (case target
             'c        ,(& *have-c-compiler?* '#'c-transpile)
             'bytecode ,(& *have-c-compiler?* '#'bc-transpile)
             'js       #'js-transpile
             'php      #'php-transpile
             'c64      #'c64-transpile
             (error "unknown target ~A"))
           sources
           :transpiler (| transpiler
                          (copy-transpiler
                            (case target
                              'c        ,(& *have-c-compiler?* '*c-transpiler*)
                              'bytecode ,(& *have-c-compiler?* '*bc-transpiler*)
                              'js       *js-transpiler*
                              'php      *php-transpiler*)))
           ,@(keyword-copiers 'obfuscate? 'print-obfuscations? 'files-to-update)))

(defun compile-sections (sections &key (target nil) (transpiler nil) (obfuscate? nil) (print-obfuscations? t) (files-to-update nil))
  (compile-0 (filter [? (string? _)
                        (list _)
                        _]
                     sections)
             ,@(keyword-copiers 'target 'transpiler 'obfuscate? 'print-obfuscations? 'files-to-update)))

(defun compile (expression &key (target nil) (transpiler nil) (obfuscate? nil) (print-obfuscations? t))
  (compile-0 (& expression
                `((compile . (,expression))))
             ,@(keyword-copiers 'target 'transpiler 'obfuscate? 'print-obfuscations?)
             :files-to-update nil))
