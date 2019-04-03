(fn %load-r (s)
  (when (peek-char s)
    (. (read s)
       (%load-r s))))

(fn %expand (x)
  (!= (quasiquote-expand (macroexpand (dot-expand x)))
    (? (equal x !)
       x
       (%expand !))))

(defbuiltin load (pathname)
  (print-definition `(load ,pathname))
  (@ (i (with-input-file s pathname
          (%load-r s)))
    (eval (%expand i))))
