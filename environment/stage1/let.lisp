(defmacro let (place expr &body body)
  (?
    (not body)
      (error "Body expected.")
    (not (symbol? place))
      (error "Place ~A is not a symbol." place)
    (keyword? place)
      (error "Place ~A: symbol expected instead of a keyword." place)
    (argument-keyword? place)
      (error "Place ~A: symbol expected instead of an argument keyword." place)
    `(#'((,place)
           ,@body)
       ,expr)))

(defmacro let* (alst &body body)
  (?
    (not alst)        `(progn
                         ,@body)
    (not (cdr alst))  `(let ,(car (car alst)) ,(car (cdr (car alst)))
                         ,@body)
    `(let ,(car (car alst)) ,(car (cdr (car alst)))
       (let* ,(cdr alst)
         ,@body))))

(defmacro let-if (x expr &body body)
  `(let ,x ,expr
     (? ,x
        ,@body)))
