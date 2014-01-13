;;;;; tré – Copyright (c) 2013 Sven Michael Klose <pixel@copei.de>

(defun filter-require-statements (x)
  (mapcan [? (& (cons? _)
                (eq 'require _.))
             (list ._)]
          x))

(defun get-requires (file)
  (with (files-read  (make-hash-table :test #'string==)
         read-file?  [href files-read _]
         mark-read   [= (href files _) t]
         f           [awhen (filter-require-statements (read-file _))
                       (adolist !
                         (mark-read !))
                       (+ ! (mapcan #'f (remove-if #'read-file? !)))])
    (f file)))

(get-requires "environment/transpiler/generic-compile.lisp")

(quit)
