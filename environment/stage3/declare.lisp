;;;;; tré – Copyright (c) 2008–2012 Sven Michael Klose <pixel@copei.de>

(defvar *type-predicates*
  '((nil . not)
    (cons . cons?)
	(list . listp)
	(atom . atom)
	(symbol . symbol?)
	(function . function?)
	(number . number?)
	(integer . number?)
	(float . number?)
	(character . character?)
	(array . array?)
 	(string . string?)
    (hash-table . hash-table?)))

(defun %declare-type-predicate (typ)
  (assoc-value typ *type-predicates*))

(defun %declare-statement-type-predicate (typ x)
  `(,(| (%declare-type-predicate typ)
        ($ typ '?))
     ,x))

(defun %declare-statement-type-1 (typ x)
  (unless (variablep x)
	(error "Variable expected but got ~A to declare as of type ~A" x typ))
  `(unless (| ,@(filter (fn %declare-statement-type-predicate _ x)
                        (force-list typ)))
	 (error "~A is not of type ~A. Object: ~A" ,(symbol-name x) (quote ,typ) ,x)))

(defun %declare-statement-type (x)
  (unless (<= 2 (length x))
	(error "expected type and one or more variables, but got only ~A" x))
  `(progn
	 ,@(filter (fn %declare-statement-type-1 x. _) .x)))

(defvar *declare-statement-classes*
  '((type .	%declare-statement-type)))

(defun %declare-statement (x)
  (funcall
      (symbol-function
	      (| (assoc-value x. *declare-statement-classes*)
	         (error "unknown declaration class ~A. Choose one of ~A instead"
		            x. (carlist *declare-statement-classes*))))
      .x))

(defmacro declare (&rest x)
  (unless x
	(error "arguments expected"))
  (let body (filter #'%declare-statement (force-tree x))
	(when *assert*
  	  `(progn
	 	 ,@body))))
