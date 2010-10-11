;;;;; Transpiler: TRE to JavaScript
;;;;; Copyright (c) 2010 Sven Klose <pixel@copei.de>

(cps-exception t)

(defvar *%property-list-tmp* nil)

(defun %property-list-0 (key val)
  (push! (cons key val) *%property-list-tmp*))

(dont-inline %property-list)
(dont-obfuscate fun i hash)

(defun %property-list (hash )
  (setf *%property-list-tmp* nil)
  (%transpiler-native
      "null;for (i in hash) "
      ,(transpiler-obfuscated-symbol-string *js-transpiler*
           (compiled-function-name '%property-list-0))
      "(i, hash[i]);")
  (reverse *%property-list-tmp*))

(cps-exception nil)
