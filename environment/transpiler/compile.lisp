;;;;; tré - Copyright (c) 2008-2012 Sven Michael Klose <pixel@copei.de>

(defun compile-0 (sources &key (target nil) (obfuscate? nil) (print-obfuscations? nil) (files-to-update nil))
  (?
    (not target) (error "target missing")
    (eq 'c target) ,(when *have-c-compiler?* '(c-transpile sources :obfuscate? obfuscate?))
    (eq 'js target) (js-transpile sources :obfuscate? obfuscate? :print-obfuscations? :print-obfuscations? :files-to-update files-to-update)
    (eq 'php target) (php-transpile sources :obfuscate? obfuscate? :print-obfuscations? :print-obfuscations? :files-to-update files-to-update)
    (error "unknown target ~A")))

(defun compile-files (files &key (target nil) (obfuscate? nil) (print-obfuscations? nil) (files-to-update nil))
  (compile-0 (mapcar #'list files)
             :target target :obfuscate? obfuscate? :print-obfuscations? print-obfuscations? :files-to-update files-to-update))

(defun compile (expression &key (target nil) (obfuscate? nil) (print-obfuscations? nil) (files-to-update nil) (section-id 'compile))
  (compile-0 (and expression (list (cons section-id (list expression))))
             :target target :obfuscate? obfuscate? :print-obfuscations? print-obfuscations? :files-to-update files-to-update))
