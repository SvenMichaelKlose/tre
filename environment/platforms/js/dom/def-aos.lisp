;;;;; tré – Copyright (c) 2010–2012 Sven Michael Klose <pixel@copei.de>

(defmacro def-aos-if (name args predicate)
  (with-gensym elm
    `(defun ,name (,elm ,@args)
       (ancestor-or-self-if ,elm ,predicate))))
