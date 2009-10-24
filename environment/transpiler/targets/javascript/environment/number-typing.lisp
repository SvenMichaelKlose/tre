;;;;; Transpiler: TRE to JavaScript
;;;;; Copyright (c) 2008-2009 Sven Klose <pixel@copei.de>

(defmacro + (&rest x)
  (if
	(not (= 2 (length x)))
	  `(+ ,@x)
	(some #'stringp x)
      `(string-concat ,@x)
	(every #'stringp x)
	  (apply #'string-concat x)
	(and (some #'characterp x) ; XXX would still mix with other types in vars
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
	    (and (some #'characterp x) ; XXX would still mix with other types in vars
		     (not (some #'integerp x)))
      	  `(,($ 'character _) ,,@x)
	    (and (some #'integerp x)
		     (not (some #'characterp x)))
      	  `(,($ 'integer _) ,,@x)
        `(,_ ,,@x)))))

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
