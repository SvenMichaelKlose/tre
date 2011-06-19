;;;;; Transpiler: TRE to JavaScript
;;;;; Copyright (c) 2010-2011 Sven Klose <pixel@copei.de>

;(cps-exception t)

(defvar *%property-list-tmp* nil)

(defun %property-list-0 (key val)
  (acons! key val *%property-list-tmp*))

(dont-inline %property-list)

(defun %property-list (hash)
  (setf *%property-list-tmp* nil)
  (%setq nil (%transpiler-native
      "for (" i " in " hash ") "
          ,(transpiler-obfuscated-symbol-string *js-transpiler* (compiled-function-name '%property-list-0))
               "(" i ", " hash "[" i "]);"))
  (reverse *%property-list-tmp*))

;(cps-exception nil)
