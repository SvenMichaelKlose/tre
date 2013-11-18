;;;;; tré – Copyright (c) 2010–2012 Sven Michael Klose <pixel@copei.de>

(defmacro def-aos (name what &rest args)
  `(defun ,name (x)
     (,($ 'ancestor-or-self- what) x ,@args)))

(defmacro def-aos-class (name classname)
  `(defun ,name (x)
     (ancestor-or-self-with-class-of x ,classname)))

(defmacro def-aos-class-many (name classname)
  `(defun ,name (x)
     (awhen (ancestor-or-self-with-class-of x ,classname)
       (cons ! (,name !.parent-node)))))

(defmacro def-aos-tag (name tagname)
  `(defun ,name (x)
     (ancestor-or-self-with-tag-name x ,tagname)))

(defmacro def-aos-if (name args predicate)
  (with-gensym elm
    `(defun ,name (,elm ,@args)
       (ancestor-or-self-if ,elm ,predicate))))
