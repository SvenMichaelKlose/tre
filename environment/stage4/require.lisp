;;;;; TRE environment
;;;;; Copyright (c) 2009 Sven Klose <pixel@copei.de>

(defvar *loaded-required-files* nil)

(define-js-std-macro require (file)
  (unless (member file *loaded-required-files* :test string=)
    (print `(require ,file))
    `(progn
       ,@(dot-expand (read-file-all file)))))
