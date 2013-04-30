;;;;; tré – Copyright (c) 2008–2013 Sven Michael Klose <pixel@copei.de>

(defmacro define-c-std-macro (&rest x)
  `(define-transpiler-std-macro *c-transpiler* ,@x))

(define-c-std-macro defun (name args &rest body)
  `(%%block
     ,(apply #'shared-defun name args body)
     ,@(let fun-name (%defun-name name)
         (c-compiled-symbol fun-name)
         (unless (simple-argument-list? args)
           (with-gensym p
             `((defun ,($ fun-name '_treexp) (,p)
                 ,(compile-argument-expansion-function-body fun-name args p nil (argument-expand-names 'compile-argument-expansion args)))))))))

(transpiler-wrap-invariant-to-binary define-c-std-macro eq 2 %%%eq &)

(define-c-std-macro slot-value (obj slot)
  `(%slot-value ,obj (%quote ,slot)))

(define-c-std-macro =-slot-value (val obj slot)
  `(=-%slot-value ,val ,obj (%quote ,slot)))

(defun single-index? (x)
  (& (== 1 (length x))
     (not (%transpiler-native? x.))
     (number? x.)))

(define-c-std-macro =-aref (val arr &rest idx)
  (? (single-index? idx)
    `(%immediate-set-aref ,val ,arr (%transpiler-native ,idx.))
    `(=-%aref ,val ,arr ,@idx)))

(define-c-std-macro aref (arr &rest idx)
  (? (single-index? idx)
     `(%immediate-aref ,arr (%transpiler-native ,idx.))
     `(%aref ,arr ,@idx)))

(define-c-std-macro %%%nanotime ()
  '(nanotime))

(define-c-std-macro filter (fun lst)
  (shared-opt-filter fun lst))

(mapcar-macro x '(car cdr cons? atom symbol? number? string? array? builtin? function? identity)
  `(progn
     (functional ,($ '% x))
     (define-c-std-macro ,x (x)
       `(,($ '% x) ,,x))))

(define-c-std-macro cons (a d)
  `(%cons ,a ,d))
