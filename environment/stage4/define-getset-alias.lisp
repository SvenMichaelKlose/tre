;;;;; tré - Copyright (c) 2009,2012 Sven Michael Klose <pixel@copei.de>

(defun get-definer (class)
  (? class
     `(defmethod ,class)
     '(defun)))

(defmacro define-alias (alias real &key (class nil))
  `(,@(get-definer class) ,alias ()
      ,real))

(defmacro define-get-alias (alias real &key (class nil))
  `(,@(get-definer class) ,($ 'get- alias) ()
      ,real))

(defmacro define-set-alias (alias real &key (class nil))
  `(,@(get-definer class) ,($ 'set- alias) (x)
      (setf ,real x)))

(defmacro define-getset-alias (alias real &key (class nil))
  `(progn
	 (define-get-alias ,alias ,real :class ,class)
	 (define-set-alias ,alias ,real :class ,class)))
