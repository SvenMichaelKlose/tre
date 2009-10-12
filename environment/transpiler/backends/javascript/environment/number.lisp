;;;;; Transpiler: TRE to JavaScript
;;;;; Copyright (c) 2008-2009 Sven Klose <pixel@copei.de>

(js-type-predicate %numberp "number")

(defmacro + (&rest x)
  (if
	(some #'stringp x)
      `(string-concat ,@x)
	(every #'stringp x)
	  (apply #'string-concat x)
	(and (some #'characterp x)
		 (not (some #'integerp x)))
      `(character+ ,@x)
	(and (some #'integerp x)
		 (not (some #'characterp x)))
      `(integer+ ,@x)
    `(+ ,@x)))

(mapcan-macro _
    '(- = < > <= >=)
  `((defmacro ,_ (&rest x)
  	  (if
		(some #'stringp x)
      	  `(,($ 'string _) ,,@x)
	    (and (some #'characterp x)
		     (not (some #'integerp x)))
      	  `(,($ 'character _) ,,@x)
	    (and (some #'integerp x)
		     (not (some #'characterp x)))
      	  `(,($ 'integer _) ,,@x)
        `(,_ ,,@x)))))

(mapcan-macro _
     '(= < > <= >=)
  `((defmacro ,($ 'character _) (x y)
      `(,($ '%%% _) (slot-value ,,x 'v)
					(slot-value ,,y 'v)))))

(defun %wrap-char-number (x)
  (if (characterp x)
	  (char-code x)
	  x))

(mapcan-macro gen
	'(+ -)
  (with (num ($ 'number gen)
		 int ($ 'integer gen)
		 op  ($ '%%% gen)
         gen-body `(let n (%wrap-char-number x.)
	    			 (dolist (i .x n)
	      			   (setf n (,op n (%wrap-char-number i))))))
  `((defun ,gen (&rest x)
	  ,gen-body)
	(defun ,num (&rest x)
	  ,gen-body)
    (defun ,int (&rest x)
      (let n x.
	    (dolist (i .x n)
	      (setf n (,op n i))))))))

(mapcan-macro _
	'(= < > <= >=)
  `((defun ,_ (x y)
      (with (xn (%wrap-char-number x)
		     yn (%wrap-char-number y))
	    (,($ '%%% _) xn yn)))
	(defun ,($ 'integer _) (x y)
	  (,_ x y))
	(defun ,($ 'character _) (x y)
	  (,_ x.v y.v))))

(defun numberp (x)
  (or (%numberp x)
	  (characterp x)))

(defun integer (x)
  (declare type number x)
  (if (characterp x)
      (char-code x)
      x))
