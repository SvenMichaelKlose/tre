;;;; TRE environment
;;;; Copyright (c) 2005-2008,2010 Sven Klose <pixel@copei.de>

; Check and return keyword argument or NIL.
(%defun %defun-arg-keyword (args)
  (let a (car args)
	(let d (and (cdr args)
				(cadr args))
      (if (%arg-keyword? a)
          (if d
              (if (%arg-keyword? d)
                  (%error "keyword following keyword"))
              (%error "end after keyword"))))))

(%defun %defun-checked-args (args)
  (if args
      (or (%defun-arg-keyword args)
          (cons (car args)
				(%defun-checked-args (cdr args))))))

(%defun %defun-name (name)
  (if (atom name)
      name
      (if (eq (car name) 'SETF)
          (make-symbol (string-concat "%%USETF-" (string (cadr name))))
          (progn
			(print name)
			(%error "illegal function name")))))

(defmacro defun (name args &rest body)
  (let name (%defun-name name)
    `(block nil
	   (if *show-definitions*
	       (print `(defun ,name)))
       (setq *universe* (cons ',name *universe*)
       		 *defined-functions* (cons ',name *defined-functions*))
       (%set-atom-fun ,name
           #'(,(%defun-checked-args args)
               (block ,name
                 ,@(%add-documentation name body))))
	   (return-from nil ',name))))
