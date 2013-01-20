;;;;; tré – Copyright (c) 2008–2013 Sven Michael Klose <pixel@copei.de>

(defmacro define-c-std-macro (&rest x)
  `(define-transpiler-std-macro *c-transpiler* ,@x))

(define-c-std-macro %defsetq (&rest x)
  `(%setq ,@x))

(define-c-std-macro %lx (lexicals fun)                                                                                                                        
  (eval (macroexpand `(with ,(mapcan ^(,_ ',_) .lexicals.)
                        ,fun))))

(define-c-std-macro not (&rest x)
  (funcall #'shared-not x))

(define-c-std-macro defun (name args &rest body)
  `(%%vm-scope
     ,(car (apply #'shared-defun name args body))
     ,@(with ((fi-sym adef) (split-funinfo-and-args args)
              fun-name      (%defun-name name))
         (unless (simple-argument-list? adef)
           (with-gensym p
             `((%setq ~%ret nil)
               (defun ,($ fun-name '_treexp) (,p)
                 ,(compile-argument-expansion-function-body fun-name adef p nil (argument-expand-names 'compile-argument-expansion adef)))))))))

(define-c-std-macro defmacro (&rest x)
  (apply #'shared-defmacro '*transpiler* x))

(define-c-std-macro defvar (name &optional (val '%%no-value))
  (& (eq '%%no-value val)
     (= name `',name))
  (let tr *transpiler*
    (print-definition `(defvar ,name))
    (& (transpiler-defined-variable tr name)
       (redef-warn "redefinition of variable ~A.~%" name))
    (transpiler-add-defined-variable tr name)
    (transpiler-obfuscate-symbol tr name)
    `(progn
       (%var ,name)
	   (%setq ,name ,val))))

(transpiler-wrap-invariant-to-binary define-c-std-macro eq 2 %eq &)

(define-c-std-macro %%u=-car (val x)
  (shared-=-car val x))

(define-c-std-macro %%u=-cdr (val x)
  (shared-=-cdr val x))

(mapcan-macro _
    '(car cdr cons? atom number? string? array? function? builtin?)
  (let n ($ '% _)
  `((functional ,n)
    (define-c-std-macro ,_ (x)
	  `(,n ,,x)))))

(define-c-std-macro slot-value (obj slot)
  `(%slot-value ,obj (%quote ,slot)))

(define-c-std-macro %%u=-slot-value (val obj slot)
  `(%%u=-%slot-value ,val ,obj (%quote ,slot)))

(defun single-index? (x)
  (& (== 1 (length x))
     (not (%transpiler-native? x.))
     (number? x.)))

(define-c-std-macro %%u=-aref (val arr &rest idx)
  (? (single-index? idx)
    `(%immediate-set-aref ,val ,arr (%transpiler-native ,idx.))
    `(%set-aref ,(compiled-list `(,val ,arr ,@idx)))))

(define-c-std-macro aref (arr &rest idx)
  (? (single-index? idx)
     `(%immediate-aref ,arr (%transpiler-native ,idx.))
     `(%aref ,(compiled-list (cons arr idx)))))
	  
(define-c-std-macro mapcar (fun &rest lsts)
  (apply #'shared-mapcar fun lsts))

(define-c-std-macro %%%nanotime ()
  '(nanotime))

(define-c-std-macro filter (fun lst)
  (shared-opt-filter fun lst))
