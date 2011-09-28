;;;;; tré - Copyright (c) 2011 Sven Klose <pixel@copei.de>

(defun process-%%in-package (x)
  (?
    (atom x) x
    (eq '%quote x.) x
    (eq '%%in-package x.)
      (and (setf (transpiler-current-package *current-transpiler*) (make-package (symbol-name .x.)))
           nil)
    (cons (process-%%in-package x.)
          (process-%%in-package .x))))

(defun make-packages-0 (x)
  (?
    (not x) x
    (symbol? x)
      (let packaged-symbol (transpiler-package-symbol *current-transpiler* x)
        (? (transpiler-defined-function *current-transpiler* packaged-symbol)
           packaged-symbol
           x))
    (atom x) x
    (eq '%%in-package x.)
      (and (setf (transpiler-current-package *current-transpiler*) (make-package (symbol-name .x.)))
           nil)
    (cons (make-packages-0 x.)
          (make-packages-0 .x))))

(defun make-packages (x)
  (let processed (process-%%in-package x)
    (? (transpiler-current-package *current-transpiler*)
       (make-packages-0 processed)
       processed)))
