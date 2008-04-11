;;;; nix operating system project
;;;; list processor environment
;;;; Copyright (C) 2005-2007 Sven Klose <pixel@copei.de>
;;;;
;;;; FORMAT function

(defun %format-directive (str l i txt args)
   (let ((el (char-upcase (elt txt i))))
     (cond
       ((= el #\%)  (terpri str)
                      (%format str l (1+ i) txt args))
       ((= el #\A)  (if (listp (car args))
                        (print (car args))
                        (princ (car args) str))
                    (%format str l (1+ i) txt (cdr args)))
       (t           (princ #\~)
                    (%format str l i txt args)))))

(defun %format (str l i txt args)
  (when (< i l)
    (if (= (elt txt i) #\~)
      (%format-directive str l (1+ i) txt args)
      (progn
        (princ (elt txt i) str)
        (%format str l (1+ i) txt args)))))

(defun format (str txt &rest args)
  "Print formatted string."
  (with-default-stream str
        (%format str (length txt) 0 txt args)))

(defun error (format &rest args)
  (%error (apply #'format nil args)))
