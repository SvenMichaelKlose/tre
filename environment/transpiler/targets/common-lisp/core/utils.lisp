;;;; tré – Copyright (c) 2008–2014 Sven Michael Klose <pixel@copei.de>

(defun group (x size)
  (cond
    ((not x) nil)
    ((< (length x) size) (list x))
    (t (cons (subseq x 0 size)
             (group (nthcdr size x) size)))))

(defmacro ? (&body body)
  (let* ((tests (group body 2))
         (end   (car (last tests))))
    (unless body
      (error "Body is missing."))
    `(cond
       ,@(if (= 1 (length end))
             (append (butlast tests) (list (cons t end)))
             tests))))

(defmacro !? (x &rest y)
  `(let ((! ,x))
     (? !
        ,@y)))

(defmacro alet (x &rest body)
  `(let ((! ,x))
     ,@body))

(defmacro awhen (x &rest body)
  `(alet ,x
     (when !
       ,@body)))

(defmacro let-when (x expr &body body)
  `(let ((,x ,expr))
	 (when ,x
	   ,@body)))

(defmacro with-gensym (x &rest body)
  `(let ((,x (gensym)))
     ,@body))

(defmacro with-temporary (place val &body body)
  (with-gensym old-val
    `(let ((,old-val ,place))
       (setf ,place ,val)
       (prog1
         (progn
           ,@body)
         (setf ,place ,old-val)))))

(defmacro with-temporaries (lst &body body)
  (or lst (error "Assignment list expected."))
  `(with-temporary ,(car lst) ,(cadr lst)
     ,@(? (cddr lst)
          `((with-temporaries ,(cddr lst) ,@body))
          body)))

(defmacro with-stream-string (str x &body body)
  `(let ((,str (make-string-input-stream ,x)))
     ,@body))

(defmacro in? (obj &rest lst)
  `(or ,@(mapcar #'(lambda (x) `(eq ,obj ,x)) lst)))

(defmacro in=? (obj &rest lst)
  `(or ,@(mapcar #'(lambda (x) `(char= ,obj ,x)) lst)))

(defun carlist (x) (mapcar #'car x))
(defun cdrlist (x) (mapcar #'cdr x))

(defun split (obj seq &key (test #'eql) (include? nil))
  (and seq
       (alet (position obj seq :test test)
         (? !
            (cons (subseq seq 0 (? include? (+ 1 !) !))
                  (split obj (subseq seq (+ 1 !)) :test test :include? include?))
            (list seq)))))

(defun tree-walk (i &key (ascending nil) (dont-ascend-if nil) (dont-ascend-after-if nil))
  (? (atom i)
	 (funcall ascending i)
	 (let* ((y (car i))
            (a (or (and dont-ascend-if (funcall dont-ascend-if y) y)
                   (? (and dont-ascend-after-if (funcall dont-ascend-after-if y))
                      (funcall ascending y)
                      (tree-walk (? ascending
                                    (funcall ascending y)
                                    y)
                                 :ascending ascending
                                 :dont-ascend-if dont-ascend-if
                                 :dont-ascend-after-if dont-ascend-after-if)))))
       (cons a (tree-walk (cdr i) :ascending ascending
                                  :dont-ascend-if dont-ascend-if
                                  :dont-ascend-after-if dont-ascend-after-if)))))
