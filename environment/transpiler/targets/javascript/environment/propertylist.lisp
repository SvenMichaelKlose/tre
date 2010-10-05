;;;;; Transpiler: TRE to JavaScript
;;;;; Copyright (c) 2010 Sven Klose <pixel@copei.de>

(cps-exception t)

(defvar *%property-list-tmp* nil)

(defun %property-list-0 (key val)
  (push! (cons key val) *%property-list-tmp*))

(defun %property-list (hash )
  (setf *%property-list-tmp* nil)
  (%transpiler-native
      "null;for (i in hash) "
      ,(transpiler-obfuscate *js-transpiler*
                             (compiled-function-name '%property-list-0))
      "(i, hash[i]);")
  (reverse *%property-list-tmp*))

(cps-exception nil)
