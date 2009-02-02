;;;; nix operating system project
;;;; list processor environment
;;;; Copyright (c) 2005-2008 Sven Klose <pixel@copei.de>
;;;;
;;;; Function definition

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

; Check and return argument list.
(%defun %defun-args (args)
  (if args
      (or
          (%defun-arg-keyword args)
          (cons (car args) (%defun-args (cdr args))))))

(%defun %defun-name (name)
  (if (atom name)
      name
      (if (or (eq (car name) '%%defunsetf)
			  (eq (car name) 'SETF))
          (make-symbol (string-concat "%%USETF-" (string (cadr name))))
          (%error "illegal function name"))))

(defvar *compiler-hook* nil)
(defvar *defun-name* nil)
(defvar *defined-functions* nil)

(defmacro defun (name args &rest body)
  "Define a function."
  (let name (%defun-name name)
    `(block nil
	   (if *show-definitions*
	       (print `(defun ,name)))
       (setq *universe* (cons ',name *universe*)
       		 *defined-functions* (cons ',name *defined-functions*)
			 *defun-name* name)
       (%set-atom-fun ,name
         #'(,(%defun-args args)
             (block ,name
               ,@(%add-documentation name body))))
       (if *compiler-hook*
           (compile (function ,name)))
	   (setq *defun-name* nil)
	   (return-from nil ',name))))

(defmacro self (&rest args)
  "Recursively call current DEFUNed function."
  `(,*defun-name* ,@args))
