;;;;; tré – Copyright (c) 2008–2013 Sven Michael Klose <pixel@copei.de>

(defmacro define-c-std-macro (&rest x)
  `(define-transpiler-std-macro *c-transpiler* ,@x))

(defun c-expander-name (x)
  ($ x '_treexp))

(define-c-std-macro defun (name args &rest body)
  `(%%block
     ,(apply #'shared-defun name args body)
     ,@(let fun-name (%defun-name name)
         (c-compiled-symbol fun-name)
         (unless (simple-argument-list? args)
           (with-gensym p
             `((defun ,(c-expander-name fun-name) (,p)
                 ,(compile-argument-expansion-function-body fun-name args p nil (argument-expand-names 'compile-argument-expansion args)))))))))

(define-c-std-macro eq (&rest x)
  (? ..x
     `(& (%%%eq ,x. ,.x.)
         (eq ,x. ,@..x))
     `(%%%eq ,@x)))

(define-c-std-macro slot-value (obj slot)
  `(%slot-value ,obj (%quote ,slot)))

(define-c-std-macro =-slot-value (val obj slot)
  `(=-%slot-value ,val ,obj (%quote ,slot)))

(defun single? (x)
  (== 1 (length x)))

(defun make-number-%%native (x)
  (? (number? x)
     `(%%native ,x)
     x))

(defun c-fast-aref? (idx)
  (& (not (transpiler-assert? *transpiler*))
     (single? idx)))

(define-c-std-macro =-aref (val arr &rest idx)
  (? (c-fast-aref? idx)
    `(%immediate-=-aref ,val ,arr ,(make-number-%%native idx.))
    `(=-aref ,val ,arr ,@idx)))

(functional %immediate-aref)

(define-c-std-macro aref (arr &rest idx)
  (? (c-fast-aref? idx)
     `(%immediate-aref ,arr ,(make-number-%%native idx.))
     `(aref ,arr ,@idx)))

(define-c-std-macro %%%nanotime ()
  '(nanotime))

(define-c-std-macro filter (fun lst)
  (shared-opt-filter fun lst))


(functional %+ %-)

(define-c-std-macro number+ (&rest x)
  (alet `(%+ ,x. ,.x.)
    (? ..x
       `(%+ ,! (number+ ,@..x))
       !)))

(define-c-std-macro number- (&rest x)
  (? ..x
     `(%- ,x. (number+ ,@.x))
     `(%- ,@x)))

(define-c-std-macro integer+ (&rest x) `(number+ ,@x))
(define-c-std-macro character+ (&rest x) `(number+ ,@x))
(define-c-std-macro integer- (&rest x) `(number- ,@x))
(define-c-std-macro character- (&rest x) `(number- ,@x))
