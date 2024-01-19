(fn read-eval-loop (&key (in *standard-input*)
                         (out *standard-output*))
  (while (peek-char in) nil
    (format out "* ~F")
    (late-print (eval (refine (compose #'dot-expand
                                       #'macroexpand
                                       #'quasiquote-expand)
                              (read in)))
                out)))
