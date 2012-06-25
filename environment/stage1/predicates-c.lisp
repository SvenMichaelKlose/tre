;;;;; tré – Copyright (c) 2005–2006,2008–2009,2011–2012 Sven Michael Klose <pixel@copei.de>

(defun symbol? (x)
  (and (atom x)
       (not (== 0 (length (symbol-name x))))))
