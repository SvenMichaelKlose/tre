;;;;; tré – Copyright (c) 2010–2013 Sven Michael Klose <pixel@copei.de>

(defvar *%property-list-tmp* nil)

(defun %property-list-0 (key val)
  (acons! key val *%property-list-tmp*))

(dont-inline %property-list)

(defun %property-list (hash)
  (= *%property-list-tmp* nil)
  (%setq nil (%%native
                 "for (var k in " hash ") "
                     "if (k != \"" '__tre-object-id "\" && k != \"" '__tre-test "\") "
                         ,(compiled-function-name-string *transpiler* '%property-list-0) "(typeof k == \"string\" ? (" *obj-keys* "[k] || k) : k, " hash "[k]);"))
  (reverse *%property-list-tmp*))
