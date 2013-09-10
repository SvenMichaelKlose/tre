;;;;; tré – Copyright (c) 2013 Sven Michael Klose <pixel@copei.de>

(dont-obfuscate *date get-time)

(defun nanotime ()
  (* 1000 ((new *date).get-time)))
