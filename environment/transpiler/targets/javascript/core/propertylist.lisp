;;;;; tré – Copyright (c) 2010–2013 Sven Michael Klose <pixel@copei.de>

(declare-cps-exception %property-list-0 %property-list)

(defvar *%property-list-tmp* nil)

(defun %property-list-0 (key val)
  (acons! key val *%property-list-tmp*))

(defun %property-list (hash)
  (= *%property-list-tmp* nil)
  (%= nil (%%native
              "for (var k in " hash ") "
                  "if (k != \"" ,(obfuscated-identifier '__tre-object-id) "\" && k != \"" ,(obfuscated-identifier '__tre-test) "\") "
                      ,(compiled-function-name-string '%property-list-0) "(typeof k == \"string\" ? (" *obj-keys* "[k] || k) : k, " hash "[k]);"))
  (reverse *%property-list-tmp*))
