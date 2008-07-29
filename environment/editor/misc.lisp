;;;;; TRE environment - editor
;;;;; Copyright (c) 2008 Sven Klose <pixel@copei.de>
;;;;;
;;;;; Miscellaneous.

(defmacro compose (&rest function-list)
  "Combine functions into one. All with one argument."
  (with (rec #'((l)
				  `(,(car l) ,(if (cdr l)
				   				  (rec (cdr l))
				   				  'x))))
    `#'((x)
		  ,(rec function-list))))

;(define-test "COMPOSE"
;  ((compose a b))
;  #'((x) (a (b x))))

(defun $ (&rest args)
  "Converts arguments to strings, concatenates them and makes a symbol."
  (make-symbol (apply #'string-concat (mapcar #'string args))))

(define-test "$"
  (($ "DOLLAR-" 'test))
  'dollar-test)

(defmacro repeat (n &rest body)
  "Execute body n times. See also DOTIMES."
  `(dotimes (,(gensym) ,n)
	 ,@body))

(defmacro define-template-macro (name head &optional tail)
   "Define simple head/tail template."
  `(defmacro ,name (n args &rest b)
 	 (with (description (and b (consp b) (stringp (first b)) (first b))
			body (if description (cdr b) b))
       `(defun ,,n ,,args
		  ,,@(list description)
          ,@head
          ,,@body
          ,@tail))))

(defmacro define-tail-macro (name tail)
  `(define-template-macro ,name nil ,tail))
