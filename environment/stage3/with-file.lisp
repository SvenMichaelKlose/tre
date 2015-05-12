; tré – Copyright (c) 2005–2006,2008,2011–2013,2015 Sven Michael Klose <pixel@copei.de>

(defmacro with-open-file (var file &body body)
  (with-gensym g
    `(with (,var ,file
            ,g   (progn ,@body))
       (close ,var)
       ,g)))

(defmacro with-file (f path direction &body body)
  `(with-open-file ,f (open ,path :direction ,direction)
     ,@body))

(defmacro with-input-file (f path &body body)
  `(with-file ,f ,path 'input
     ,@body))

(defmacro with-output-file (f path &body body)
  `(with-file ,f ,path 'output
     ,@body))

(defmacro with-input-output-file (i ipath o opath &body body)
  `(with-input-file ,i, ipath
     (with-output-file ,o ,opath
       ,@body)))
