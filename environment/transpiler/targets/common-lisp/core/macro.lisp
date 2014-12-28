; tré – Copyright (c) 2014 Sven Michael Klose <pixel@copei.de>

(defbuiltin macro? (x) (cl:rassoc x *macros* :test #'eq))

(defvar *macroexpand-hook* nil)

(defbuiltin macroexpand-1 (x)
  (? *macroexpand-hook*
     (apply *macroexpand-hook* (list x))
     x))

(defun macroexpand-0 (old x)
  (? (equal x old)
     old
     (macroexpand x)))

(defbuiltin macroexpand (x)
  (macroexpand-0 x (macroexpand-1 x)))
