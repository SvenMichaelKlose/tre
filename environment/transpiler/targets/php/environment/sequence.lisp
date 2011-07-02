;;;;; Transpiler: TRE to PHP
;;;;; Copyright (c) 2008-2011 Sven Klose <pixel@copei.de>

(dont-obfuscate sizeof strlen)

(defun length (x)
  (?
    (not x) x
    (cons? x) (%list-length x)
    (string? x) (strlen x)
    (sizeof x)))

(defun split (obj seq &key (test #'eql))
  (? (and (eq #'eql test)
          (string? seq))
     (array-list (explode (? (character? obj)
                             (char-string obj)
                             obj)
                          seq))
     (generic-split obj seq)))
