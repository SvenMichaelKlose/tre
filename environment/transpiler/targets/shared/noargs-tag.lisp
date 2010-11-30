;;;;; Transpiler: TRE to JavaScript
;;;;; Copyright (c) 2008-2010 Sven Klose <pixel@copei.de>

(defun list-without-noargs-tag (x)
  (remove 'no-args x))

(defun body-with-noargs-tag (body)
  `(no-args ,@body))

(defun body-has-noargs-tag? (body)
  (eq 'no-args body.))

(defun body-without-noargs-tag (body)
  (if (body-has-noargs-tag? body)
      .body
      body))
