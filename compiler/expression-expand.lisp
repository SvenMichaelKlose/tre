;;;;; nix operating system project
;;;;; lisp compiler
;;;;; Copyright (c) 2006-2007 Sven Klose <pixel@copei.de>
;;;;;
;;;;; Expression expansion.
;;;;;
;;;;; Expand nested expressions into a sequence of instructions assigning
;;;;; unique variables. VM-SCOPEs are merged in this process.

(defvar *expexsym-counter* 0)

;; Returns newly created, unique symbol.
(defun expexsym ()
  (setf *expexsym-counter* (+ 1 *expexsym-counter*))
  (make-symbol (string-concat "~E" (string *expexsym-counter*))))

(defun expex-vmscope (q expr)
  "Merge in VMSCOPE."
  (with (e (expex-expand-body (cdr expr)))
	; If the scope contains more than one expression, place return
	; value in new variable and replace scope by the variable.
    (aif (butlast e)
      (with (s (expexsym))
        (enqueue-many q (nconc ! `((,s ,(car (last e))))))
        s)
      (car e))))

(defun expex-make-assignment (expr)
  "Makes a single statement assigment."
  (with (s (expexsym))
    (enqueue q `(,s ,expr))
    s))

(defun expex-expand (expr q)
  "Expand argument."
  (if (atom expr)
    expr
    (if (vm-scope? expr)
        (expex-vmscope q expr) ; Make VMSCOPEs disappear.
        (with-cons a d expr
          (if (in? a '%funref 'vm-go 'vm-go-nil '%stack 'quote)
              expr
              (expex-make-assignment (cons a (expex-expand-args d q))))))))

(defun expex-expand-args (args q)
  "Move arguments to new assignments."
  (mapcar #'((a)
			   (expex-expand a q))
          args))

(defun force-setq (x)
  (if (vm-go? x)
	  x
	  (list (expexsym) x)))

(defun expex-expand-toplevel (expr q)
  "Expand an expression or return atom as is."
  (if (consp expr)
      (enqueue q (cons (car expr) (expex-expand-args (cdr expr) q)))
   	  (enqueue q expr)))

(defun expex-expand-body (body)
  "Expand list of expressions."
  (when body
    (if (vm-scope? body)
      (expex-expand-body (cdr body))
      (with-queue q
        (dolist (e body)
          (if (vm-scope? e)
            (enqueue-many q (expex-expand-body (cdr e)))
            (expex-expand-toplevel e q)))
        (queue-list q)))))
