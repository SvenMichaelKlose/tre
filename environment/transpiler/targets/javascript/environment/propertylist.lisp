;;;;; tré - Copyright (c) 2010-2011 Sven Klose <pixel@copei.de>

(defvar *%property-list-tmp* nil)

(defun %property-list-0 (key val)
  (acons! key val *%property-list-tmp*))

(dont-inline %property-list)

(defun %property-list (hash)
  (setf *%property-list-tmp* nil)
  (%setq nil (%transpiler-native
      "for (var " i " in " hash ") "
          ,(compiled-function-name-string *js-transpiler* '%property-list-0)
               "(" i ", " hash "[" i "]);"))
  (reverse *%property-list-tmp*))
