;;;;; TRE to PHP transpiler
;;;;; Copyright (c) 2009,2011 Sven Klose <pixel@copei.de>

(defun hash-table? (x)
  (array? x))

(defun hash-assoc (x)
  (let lst nil
    (map (fn (nconc! lst (list (cons _ (href x _)))))
         x)
    lst))
