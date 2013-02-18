;;;;; tré – Copyright (c) 2008–2013 Sven Michael Klose <pixel@copei.de>

(defun bc-transpile (sources &key transpiler obfuscate? print-obfuscations? files-to-update)
  (alet (target-transpile transpiler :files-after-deps sources)
    (& *show-definitions?*
       (format t "; ~A codes.~%" (length !)))
    (expr-to-code transpiler !)))
