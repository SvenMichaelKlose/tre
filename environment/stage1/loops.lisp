;;;; nix operating system project
;;;; list processor environment
;;;; Copyright (C) 2005-2007 Sven Klose <pixel@copei.de>
;;;;
;;;; Loop macros

(defmacro dotimes ((iter times &rest result) &rest body)
  (let ((tag (gensym))
	(m (gensym)))
    `(block nil
      (let ((,iter 0)
            (,m ,times))
        (tagbody
          ,tag
          (if (not (< ,iter ,m))
            (return (progn ,@result)))
          ,@body
          (setq ,iter (+ ,iter 1))
	  (go ,tag))))))


(defmacro do (binds (test &rest result) &rest body)
  (let ((tag (gensym)))
    `(block nil
      (let (,@(mapcar #'(lambda (b) `(,(first b) ,(second b))) binds))
        (tagbody
          ,tag
          (if ,test
            (return (progn ,@result)))
          ,@body
          ,@(mapcar #'(lambda (b) (and (third b) `(setq ,(first b) ,(third b)))) binds)
          (go ,tag))))))
