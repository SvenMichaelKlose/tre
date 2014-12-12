;;;;; tré – Copyright (c) 2014 Sven Michael Klose <pixel@hugbox.org>

(defun peek-char (str)
  (alet (cl-peek-char nil str nil 'eof)
    (unless (eq ! 'eof)
      !)))

(defun read-char (str)
  (alet (cl-read-char str nil 'eof)
    (unless (eq ! 'eof) !)))
