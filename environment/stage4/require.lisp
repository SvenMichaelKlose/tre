(var *loaded-required-files* nil)

(def-js-transpiler-macro require (file)
  (unless (member file *loaded-required-files* :test #'string==)
    (print `(require ,file))
    `(progn
       ,@(dot-expand (read-file file)))))
