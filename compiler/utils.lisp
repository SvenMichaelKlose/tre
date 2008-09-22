;;;; nix operating system project
;;;; lisp compiler
;;;; Copyright (C) 2005-2008 Sven Klose <pixel@copei.de>
;;;;
;;;; Miscellaneous utilities.

(defun enqueue-many (q l)
  (dolist (e l)
    (enqueue q e)))

(defmacro with-cons (a d c &rest body)
  `(let ((,a (car ,c))
         (,d (cdr ,c)))
     ,@body))

(defun print-symbols (forms)
  (dolist (i forms)
    (verbose " ~A" (symbol-name i))))

(defmacro t? (x)
  `(eq t ,x))

(defun assoc-splice (x)
  (values (carlist x) (cdrlist x)))

(defun repeat-while-changes (fun x)
 (with (new (funcall fun x))
   (if (equal x new)
       x
       (repeat-while-changes fun new))))

(defun find-tree (x v)
  (or (equal x v)
      (when (consp x)
        (or (find-tree (car x) v)   
            (find-tree (cdr x) v)))))

(defmacro clr (&rest places)
  `(setf ,@(mapcan #'((x)
                        `(,x nil))
                   places)))

(defmacro with-temporary (place val &rest body)
  (with-gensym old-val
    `(with (,old-val ,place)
       (setf ,place ,val)
       (prog1
         (progn
           ,@body)
         (setf ,place ,old-val)))))
