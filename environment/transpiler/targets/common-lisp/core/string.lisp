;;;;; tré – Copyright (c) 2014 Sven Michael Klose <pixel@copei.de>

(defun string-concat (&rest x) x (apply #'cl:concatenate 'cl:string x))

(defun string (x)
  (? (cl:numberp x)
     (cl:format nil "~A" x)
     (cl:string x)))

(defun string== (a b) (cl:string= a b))

(defun list-string (x)
  (apply #'concatenate 'cl:string (cl:mapcar #'(lambda (x)
                                                 (cl:string (? (cl:numberp x)
                                                               (cl:code-char x)
                                                               x)))
                                             x)))
