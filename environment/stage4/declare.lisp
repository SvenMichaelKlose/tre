;;;;; Transpiler: TRE to JavaScript
;;;;; Copyright (c) 2008-2009 Sven Klose <pixel@copei.de>

(defvar *type-predicates*
  '((cons . consp)
	(atom . atom)
	(function . functionp)
	(number . numberp)
	(integer . numberp)
	(float . numberp)
	(character . characterp)
	(array . arrayp)
 	(string . stringp)))

(defun type-predicate (typ)
  (assoc-value typ *type-predicates*))

(defun %declare-statement-type-predicate-1 (typ x)
  `(,(if typ
         (or (type-predicate typ)
             (error "expected variable type but got ~A. Use one of ~A instead"
                    .typ. (carlist *type-predicates*)))
	     'not) ,x))

(defun %declare-statement-type-or (typ x)
  `(or ,@(mapcar (fn %declare-statement-type-predicate-1 _ x)
				 typ)))

(defun %declare-statement-type-predicate (typ x)
  (if (atom typ)
	  (%declare-statement-type-predicate-1 typ x)
	  (%declare-statement-type-or typ x)))

(defun %declare-statement-type-1 (typ x)
  (unless (variablep x)
	(error "Variable expected but got ~A to declare as of type ~A" x typ))
  `(unless ,(%declare-statement-type-predicate typ x)
	 (error "~A is not of type ~A" ,(symbol-name x) ,(when (atom typ) (symbol-name typ)))))

(defun %declare-statement-type (x)
  (unless (<= 2 (length x))
	(error "expected type and one or more variables, but got only ~A" x))
  `(progn
	 ,@(mapcar (fn %declare-statement-type-1 x. _)
			   .x)))

(defconstant *declare-statement-classes*
  '((type .	%declare-statement-type)))

(defun %declare-statement (x)
  (funcall
    (symbol-function
	  (or (assoc-value x. *declare-statement-classes*)
	      (error "unknown declaration class ~A. Choose one of ~A instead"
			     x. (carlist *declare-statement-classes*))))
    .x))

(defmacro declare (&rest x)
  "Declare type of a variable. Generates ASSERT expression."
  (unless x
	(error "arguments expected"))
  (let body (mapcar #'%declare-statement (force-tree x))
	(when *assert*
  	  `(progn
	 	 ,@body))))
