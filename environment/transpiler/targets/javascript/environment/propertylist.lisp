;;;;; tré – Copyright (c) 2010–2012 Sven Michael Klose <pixel@copei.de>

(defvar *%property-list-tmp* nil)

(defun %property-list-0 (key val)
  (acons! key val *%property-list-tmp*))

(dont-inline %property-list)

(defun %property-list (hash)
  (setf *%property-list-tmp* nil)
  (%setq nil (%transpiler-native
                 "for (var k in " hash ") "
                     "if (k != \"" '__tre-object-id "\" && k != \"" '__tre-test "\") "
                         ,(compiled-function-name-string *js-transpiler* '%property-list-0) "(typeof k == \"string\" ? (OBJKEYS[k] || k) : k, " hash "[k]);"))
  (reverse *%property-list-tmp*))
