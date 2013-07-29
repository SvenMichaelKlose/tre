;;;; tré – Copyright (c) 2005–2006,2008,2011–2013 Sven Michael Klose <pixel@copei.de>

(defmacro with-open-file (var file &rest body)
  (with-gensym g
    `(with (,var ,file
            ,g   (progn ,@body))
       (close ,var)
       ,g)))

(defmacro with-file (f path direction &rest body)
  `(with-open-file ,f (open ,path :direction ,direction)
     ,@body))

(defmacro with-input-file (f path &rest body)
  `(with-file ,f ,path 'input
     ,@body))

(defmacro with-output-file (f path &rest body)
  `(with-file ,f ,path 'output
     ,@body))
