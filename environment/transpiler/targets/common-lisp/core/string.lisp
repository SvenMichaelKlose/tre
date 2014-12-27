; tré – Copyright (c) 2014 Sven Michael Klose <pixel@copei.de>

(defbuiltin string-concat (&rest x)
  (apply #'cl:concatenate 'cl:string x))

(defbuiltin string (x)
  (? (cl:numberp x)
     (cl:format nil "~A" x)
     (cl:string x)))

(defbuiltin string== (a b) (cl:string= a b))

(defbuiltin list-string (x)
  (apply #'cl:concatenate
         'cl:string
         (cl:mapcar #'(lambda (x)
                        (cl:string (? (cl:numberp x)
                                      (cl:code-char x)
                                      x)))
                    x)))
