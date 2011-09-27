;;;;; tré - Copyright (c) 2011 Sven Klose <pixel@copei.de>

(defun make-packages-0 (x)
  (?
    (not x) x
    (symbol? x)
      (let packaged-symbol (make-symbol (symbol-name x) (transpiler-current-package *current-transpiler*))
        (? (transpiler-defined-function *current-transpiler* packaged-symbol)
           packaged-symbol
           x))
    (atom x) x
    (cons (make-packages-0 x.)
          (make-packages-0 .x))))

(defun make-packages (x)
  (? (transpiler-current-package *current-transpiler*)
     (make-packages-0 x)
     x))
