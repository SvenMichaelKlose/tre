;;;;; tré – Copyright (c) 2011–2013 Sven Michael Klose <pixel@copei.de>

(defun process-%%in-package (x)
  (?
    (atom x) x
    (eq '%quote x.) x
    (eq '%%in-package x.)
      (& (= (transpiler-current-package *current-transpiler*) (& .x. (make-package (symbol-name .x.))))
         nil)
    (cons-r process-%%in-package x)))

(defun make-packages-0 (x)
  (let tr *current-transpiler*
    (?
      (not x) x
      (& (symbol? x)
         (not (symbol-package x)))
        (let packaged-symbol (transpiler-package-symbol tr x) ; XXX into own function
          (? (transpiler-defined-function tr packaged-symbol)
             packaged-symbol
             x))
      (atom x) x
      (eq '%%in-package x.)
        (& (= (transpiler-current-package tr) (& .x. (make-package (symbol-name .x.))))
           nil)
      (%slot-value? x) x
      (progn
        (make-default-listprop x)
        (cons-r make-packages-0 x)))))

(defun make-packages (x)
  (let processed (process-%%in-package x)
    (? (transpiler-current-package *current-transpiler*)
       (make-packages-0 processed)
       processed)))
