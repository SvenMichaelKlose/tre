;;;; tré – Copyright (c) 2008–2010,2013 Sven Michael Klose <pixel@copei.de>

(defun pad (seq p)
  (!? seq
      (cons !. (& .!
                  (cons p (pad .! p))))))
