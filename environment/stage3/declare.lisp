; tré – Copyright (c) 2008–2013,2015–2016 Sven Michael Klose <pixel@copei.de>

(defvar *type-predicates*
  '((nil        . not)
    (cons       . cons?)
	(list       . list?)
	(atom       . atom)
	(symbol     . symbol?)
	(function   . function?)
	(number     . number?)
	(integer    . number?)
	(float      . number?)
	(character  . character?)
	(array      . array?)
 	(string     . string?)
    (hash-table . hash-table?)))

(defun %declare-type-predicate (typ)
  (assoc-value typ *type-predicates*))

(defun %declare-statement-type-predicate (typ x)
  `(,(| (%declare-type-predicate typ)
        ($ typ '?))
    ,x))

(defun %declare-statement-type-1 (typ x)
  (| (symbol? x)
	 (error "Symbol expected but got ~A to declare as of type ~A." x typ))
  `(unless (| ,@(@ [%declare-statement-type-predicate _ x]
                   (ensure-list typ)))
	 (error "~A is not of type ~A. Object: ~A." ,(symbol-name x) (quote ,typ) ,x)))

(defun %declare-statement-type (x)
  (| (<= 2 (length x))
	 (error "Expected type and one or more variables, but got only ~A." x))
  `{,@(@ [%declare-statement-type-1 x. _] .x)})

(defvar *declare-statement-classes*
  '((type .	%declare-statement-type)))

(defun %declare-statement (x)
  (funcall (symbol-function (| (assoc-value x. *declare-statement-classes*)
	                        (error "Unknown declaration class ~A. Choose one of ~A instead."
		                           x. (carlist *declare-statement-classes*))))
           .x))

(defmacro declare (&rest x)
  (| x (error "Arguments expected."))
  (alet (@ #'%declare-statement (ensure-tree x))
	(when *assert?*
  	  `{,@!})))
