;;;; TRE environment
;;;; Copyright (c) 2008 Sven Klose <pixel@copei.de>

(defun lambda-args-expanded (x)
  (argument-expand-names 'lambda-args-expanded (lambda-args x)))
