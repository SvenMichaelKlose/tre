;;;;; tré – Copyright (c) 2008–2013 Sven Michael Klose <pixel@copei.de>

(defun bc-transpile (sources &key transpiler (obfuscate? nil) (files-to-update nil) (print-obfuscations? nil))
  (expr-to-code transpiler (target-transpile transpiler :files-after-deps sources)))
