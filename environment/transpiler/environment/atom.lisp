;;;;; TRE transpiler environment
;;;;; Copyright (c) 2008-2009,2011 Sven Klose <pixel@copei.de>

(defun atom (x)
  (not (cons? x)))

(defun identity (x) x)
