; tré – Copyright (c) 2013,2016 Sven Michael Klose <pixel@copei.de>

(defmacro define-gensym-generator (name prefix)
  (let var ($ '* name '-counter*)
    `{(defvar ,var 0)
      (defun ,name ()
        (alet ($ ',prefix (++! ,var))
          (? (& (eq ! (symbol-value !))
                (not (symbol-function !)))
             !
             (,name))))}))
