;;;;; tré – Copyright (c) 2013 Sven Michael Klose <pixel@copei.de>

(defun read-eval-loop (&key (in *standard-input*) (out *standard-output*))
  (while (not (end-of-file? in))
         nil
    (princ "* " out)
    (late-print (eval (repeat-while-changes (compose #'dot-expand #'macroexpand #'quasiquote-expand)
                                            (read in)))
                out)))
