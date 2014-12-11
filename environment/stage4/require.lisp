;;;;; tré – Copyright (c) 2009,2012,2014 Sven Michael Klose <pixel@hugbox.org>

(defvar *loaded-required-files* nil)

(define-js-std-macro require (file)
  (unless (member file *loaded-required-files* :test #'string==)
    (print `(require ,file))
    `(progn
       ,@(dot-expand (read-file file)))))
