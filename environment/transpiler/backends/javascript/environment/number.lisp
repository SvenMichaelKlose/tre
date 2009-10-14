;;;;; Transpiler: TRE to JavaScript
;;;;; Copyright (c) 2008-2009 Sven Klose <pixel@copei.de>

(js-type-predicate %numberp "number")

(defmacro + (&rest x)
  (if
	(not (= 2 (length x)))
	  `(+ ,@x)
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

;(mapcan-macro _
;     '(+ - = < > <= >=)
;  `((defmacro ,($ 'character _) (x y)
;      `(,($ '%%% _) (slot-value ,,x 'v)
;					(slot-value ,,y 'v)))
;    (defmacro ,($ 'integer _) (x y)
;      `(,($ '%%% _) ,,x ,,y))))

(defun %wrap-char-number (x)
  (if (characterp x)
	  (char-code x)
	  x))

(mapcan-macro gen
	'(+ -)
  (with (num ($ 'number gen)
		 int ($ 'integer gen)
		 chr ($ 'character gen)
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
	        (setf n (,op n i)))))
      (defun ,chr (&rest x)
        (let n 0
	   	  (dolist (i .x (code-char n))
		    (setf n (,op n (%wrap-char-number i)))))))))

(mapcan-macro _
	'(= < > <= >=)
  (let op ($ '%%% _)
    `((defun ,_ (x y)
        (with (xn (%wrap-char-number x)
		       yn (%wrap-char-number y))
	      (,op xn yn)))
	  (defun ,($ 'integer _) (x y)
	    (,op x y))
	  (defun ,($ 'character _) (x y)
	    (,op x.v y.v)))))

(defun numberp (x)
  (or (%numberp x)
	  (characterp x)))

(defun integer (x)
  (declare type number x)
  (if (characterp x)
      (char-code x)
      x))


;; Make inliners for CHARACTER arithmetics.
(mapcan-macro _
    '(+ = < > <= >=)
  (with (charname ($ 'character _)
         op		  ($ '%%% _))
    `((defmacro ,charname (&rest x)
        (if (= 2 (length x))
            `(,op (%slot-value ,,x. v)
                  (%slot-value ,,.x. v))
            `(,charname ,,@x)))
      (defmacro ,($ 'integer _) (&rest x)
		`(,op ,,@x)))))

(defmacro character- (&rest x)
  (if (= 1 (length x))
     `(%transpiler-native "(-" (%slot-value ,x. v) ")")
     `(%%%- ,@(mapcar (fn (if (integerp _)
							  _
							  `(%slot-value ,_ v)))
                      x))))

(defmacro integer- (&rest x)
  (if (= 1 (length x))
     `(%transpiler-native "(-" ,x. ")")
     `(%%%- ,@x)))
