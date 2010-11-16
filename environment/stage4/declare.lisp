;;;;; TRE environment
;;;;; Copyright (c) 2008-2010 Sven Klose <pixel@copei.de>

(defvar *type-predicates*
  '((nil . not)
    (cons . consp)
	(list . listp)
	(atom . atom)
	(symbol . symbolp)
	(function . functionp)
	(number . numberp)
	(integer . numberp)
	(float . numberp)
	(character . characterp)
	(array . arrayp)
 	(string . stringp)
    (hash-table . hash-table?)))

(defun %declare-type-predicate (typ)
  (assoc-value typ *type-predicates*))

(defun %declare-statement-type-predicate (typ x)
  `(,(or (%declare-type-predicate typ)
         ($ typ '?))
     ,x))

(defun %declare-statement-type-1 (typ x)
  (unless (variablep x)
	(error "Variable expected but got ~A to declare as of type ~A" x typ))
  `(unless (or ,@(mapcar (fn %declare-statement-type-predicate _ x)
                         (force-list typ)))
	 (error "~A is not of type ~A" ,(symbol-name x) (quote ,typ))))

(defun %declare-statement-type (x)
  (unless (<= 2 (length x))
	(error "expected type and one or more variables, but got only ~A" x))
  `(progn
	 ,@(mapcar (fn %declare-statement-type-1 x. _)
			   .x)))

(defvar *declare-statement-classes*
  '((type .	%declare-statement-type)))

(defun %declare-statement (x)
  (funcall
      (symbol-function
	      (or (assoc-value x. *declare-statement-classes*)
	          (error "unknown declaration class ~A. Choose one of ~A instead"
			         x. (carlist *declare-statement-classes*))))
      .x))

(defmacro declare (&rest x)
  (unless x
	(error "arguments expected"))
  (let body (mapcar #'%declare-statement (force-tree x))
	(when *assert*
  	  `(progn
	 	 ,@body))))
