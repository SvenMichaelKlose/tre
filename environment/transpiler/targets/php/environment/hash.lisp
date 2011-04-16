;;;;; TRE to PHP transpiler
;;;;; Copyright (c) 2009,2011 Sven Klose <pixel@copei.de>

(dont-obfuscate is_a)

(defun hash-table? (x)
  (is_a x "__l"))

(defun hash-assoc (x)
  (let lst nil
    (map (fn (nconc! lst (list (cons _ (href x _)))))
         x)
    lst))
