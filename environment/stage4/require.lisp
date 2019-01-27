(var *loaded-required-files* nil)

(define-js-std-macro require (file)
  (unless (member file *loaded-required-files* :test #'string==)
    (print `(require ,file))
    `{,@(dot-expand (read-file file))}))
