;;;;; tré - Copyright (c) 2009,2011-2012 Sven Michael Klose <pixel@copei.de>

(dont-obfuscate is_a)

(defun %%key (x)
  (? (is_a x "__symbol")
     (%%%string+ "~%SYM " x.n)
     x))

(defun hash-table? (x)
  (is_a x "__l"))

(defun hash-assoc (x)
  (let lst nil
    (map (fn nconc! lst `((, _ ,(href x _))))
         x)
    lst))
