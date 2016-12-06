; tré – Copyright (c) 2009,2012,2014,2016 Sven Michael Klose <pixel@hugbox.org>

(defvar *loaded-required-files* nil)

(define-js-std-macro require (file)
  (unless (member file *loaded-required-files* :test #'string==)
    (print `(require ,file))
    `{,@(dot-expand (read-file file))}))
