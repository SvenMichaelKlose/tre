;;;;; tré – Copyright (c) 2008–2012 Sven Michael Klose <pixel@copei.de>

(defun compile-0 (sources &key (target nil) (transpiler nil) (obfuscate? nil) (print-obfuscations? nil) (files-to-update nil))
  (?
    (not target) (error "target missing")
    (eq 'c target) ,(& *have-c-compiler?* '(c-transpile sources :transpiler (| transpiler *c-transpiler*) :obfuscate? obfuscate?))
    (eq 'js target) (js-transpile sources :transpiler (| transpiler *js-transpiler*) :obfuscate? obfuscate? :print-obfuscations? :print-obfuscations? :files-to-update files-to-update)
    (eq 'php target) (php-transpile sources :transpiler (| transpiler *php-transpiler*) :obfuscate? obfuscate? :print-obfuscations? :print-obfuscations? :files-to-update files-to-update)
    (error "unknown target ~A")))

(defun compile-files (files &key (target nil) (transpiler nil) (obfuscate? nil) (print-obfuscations? nil) (files-to-update nil))
  (compile-0 (mapcar #'list files)
             :target target :transpiler transpiler :obfuscate? obfuscate? :print-obfuscations? print-obfuscations? :files-to-update files-to-update))

(defun compile-sections (sections &key (target nil) (transpiler nil) (obfuscate? nil) (print-obfuscations? nil) (files-to-update nil) (section-id 'compile))
  (compile-0 sections
             :target target :transpiler transpiler :obfuscate? obfuscate? :print-obfuscations? print-obfuscations? :files-to-update files-to-update))

(defun compile (expression &key (target nil) (transpiler nil) (obfuscate? nil) (print-obfuscations? nil) (files-to-update nil) (section-id 'compile))
  (compile-0 (& expression `((,section-id . (,expression))))
             :target target :transpiler transpiler :obfuscate? obfuscate? :print-obfuscations? print-obfuscations? :files-to-update files-to-update))
