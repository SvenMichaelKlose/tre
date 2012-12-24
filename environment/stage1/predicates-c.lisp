;;;;; tré – Copyright (c) 2005–2006,2008–2009,2011–2012 Sven Michael Klose <pixel@copei.de>

(defun symbol? (x)
  (& (atom x)
     (not (== 0 (length (symbol-name x))))))

(defun integer? (x)
  (& (number? x)
     (== 0 (mod x 1))
     (not (character? x))))
