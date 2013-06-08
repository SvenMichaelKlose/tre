;;;;; tré – Copyright (c) 2011–2013 Sven Michael Klose <pixel@copei.de>

(defun process-%%in-package (x)
  (?
    (| (atom x) 
       (eq '%quote x.)) x
    (eq '%%in-package x.)
      (& (= (transpiler-current-package *transpiler*) (& .x. (make-package (symbol-name .x.))))
         nil)
    (listprop-cons x (process-%%in-package x.)
                     (process-%%in-package .x))))

(defun make-packages-0 (x)
  (let tr *transpiler*
    (?
      (not x) x
      (& (symbol? x)
         (not (symbol-package x)))
        (let packaged-symbol (transpiler-package-symbol tr x)
          (? (transpiler-defined-function tr packaged-symbol)
             packaged-symbol
             x))
      (atom x) x
      (eq '%%in-package x.)
        (& (= (transpiler-current-package tr) (& .x. (make-package (symbol-name .x.))))
           nil)
      (%slot-value? x) x
      (listprop-cons x (make-packages-0 x.)
                       (make-packages-0 .x)))))

(defun make-packages (x)
  (let processed (process-%%in-package x)
    (? (transpiler-current-package *transpiler*)
       (make-packages-0 processed)
       processed)))
