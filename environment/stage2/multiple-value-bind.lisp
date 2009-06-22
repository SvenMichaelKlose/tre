;;;; TRE environment
;;;; Copyright (C) 2005-2006 Sven Klose <pixel@copei.de>

(defmacro multiple-value-bind (forms expr &rest body)
  (let i 0
    (with-gensym (g gl)
      `(let* ((,g ,expr)
	          (,gl (cdr ,g)))
         (if (eq (first ,g) 'VALUES)
           (let* ,(mapcar #'((x)
			                   (prog1 `(,x (nth ,i ,gl))
			                          (incf i)))
		                  forms)
	         ,@body)
           (%error "VALUES expected"))))))

(defun values (&rest vals)
  (cons 'VALUES vals))
