;;;;; tré – Copyright (c) 2008–2012 Sven Michael Klose <pixel@copei.de>

(defun bc-transpile (sources &key transpiler obfuscate? print-obfuscations? files-to-update)
  (let tr transpiler
    (alet (target-transpile tr :files-after-deps sources
                               :dep-gen #'(()
                                             (transpiler-import-from-environment tr)))
      (& *show-definitions?*
         (format t "; ~A codes.~%" (length !)))
      (load-bytecode-functions (expr-to-code !)))))
