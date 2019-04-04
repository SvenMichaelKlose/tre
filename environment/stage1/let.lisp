(defmacro let (place expr &body body)
  (?
    (not body)    (error "Body expected.")
    (cons? place) (error "Place ~A is not an atom." place)
    `(#'((,place)
          ,@body) ,expr)))

(%defun %chk-place (x)
  (? (%arg-keyword? x)
     (error "Place ~A is an argument keyword." x)))

(%defun %error-if-not-unique (x)
  (%simple-map #'((i)
                    (? (< 1 (count i x))
                       (error "Place ~A is not unique." i)))
               x))

(%defun %let-places (x)
  (%simple-mapcar #'car x))

(%defun %let-chk-places (x)
  (? (atom x)
     (error "Assignment list expected instead of atom ~A." x))
  (%simple-map #'%chk-place x)
  (%simple-map #'((p)
                    p
                    (%error-if-not-unique (%let-places x)))
               x))

(defmacro let* (alst &body body)
  (?
    (not alst)        `(progn
                         ,@body)
    (not (cdr alst))  (progn
                        (%let-chk-places alst)
                        `(let ,(caar alst) ,(cadar alst)
                            ,@body))
    (progn
      (%let-chk-places alst)
      `(let ,(caar alst) ,(cadar alst)
         (let* ,(cdr alst)
           ,@body)))))

(defmacro let-if (x expr &body body)
  `(let ,x ,expr
     (? ,x
        ,@body)))
