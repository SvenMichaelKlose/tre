;;;;; tré – Copyright (c) 2008–2013 Sven Michael Klose <pixel@copei.de>

(defmacro define-c-std-macro (&rest x)
  `(define-transpiler-std-macro *c-transpiler* ,@x))

(define-c-std-macro %defsetq (&rest x)
  `(%setq ,@x))

(define-c-std-macro defun (name args &rest body)
  `(%%block
     ,(apply #'shared-defun name args body)
     ,@(with ((fi-sym adef) (split-funinfo-and-args args)
              fun-name      (%defun-name name))
         (unless (simple-argument-list? adef)
           (with-gensym p
             `((%setq ~%ret nil)
               (defun ,($ fun-name '_treexp) (,p)
                 ,(compile-argument-expansion-function-body fun-name adef p nil (argument-expand-names 'compile-argument-expansion adef)))))))))

(transpiler-wrap-invariant-to-binary define-c-std-macro eq 2 %%%eq &)

(mapcan-macro _
    '(car cdr cons? atom number? string? array? function? builtin?)
  (let n ($ '% _)
  `((functional ,n)
    (define-c-std-macro ,_ (x)
	  `(,n ,,x)))))

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
    `(%=-aref ,(compiled-list `(,val ,arr ,@idx)))))

(define-c-std-macro aref (arr &rest idx)
  (? (single-index? idx)
     `(%immediate-aref ,arr (%transpiler-native ,idx.))
     `(%aref ,(compiled-list (cons arr idx)))))

(define-c-std-macro %%%nanotime ()
  '(nanotime))

(define-c-std-macro filter (fun lst)
  (shared-opt-filter fun lst))
