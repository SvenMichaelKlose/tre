;;;;; tré – Copyright (c) 2013–2014 Sven Michael Klose <pixel@hugbox.org>

(defun read-eval-loop (&key (in *standard-input*) (out *standard-output*))
  (while (peek-char in)
         nil
    (princ "* " out)
    (late-print (eval (repeat-while-changes (compose #'dot-expand #'macroexpand #'quasiquote-expand)
                                            (read in)))
                out)))
