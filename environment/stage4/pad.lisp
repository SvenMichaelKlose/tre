;;;; tré – Copyright (c) 2008–2010,2013–2014 Sven Michael Klose <pixel@hugbox.org>

(defun pad (seq p)
  (!? seq
      (. !.  (& .!
                (. p (pad .! p))))))
