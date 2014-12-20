;;;;; tré – Copyright (c) 2005–2009,2011–2014 Sven Michael Klose <pixel@copei.de>

(functional append)

(defun append (&rest lists)
  (when lists
    (let f nil
      (let l nil
        (dolist (i lists f)
          (when i
            (? l
               (setq l (last (rplacd l (copy-list i))))
               (setq f (copy-list i)
                     l (last f)))))))))
