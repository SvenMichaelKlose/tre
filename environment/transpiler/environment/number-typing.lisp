;;;;; TRE transpiler environment
;;;;; Copyright (c) 2008-2011 Sven Klose <pixel@copei.de>

(defmacro + (&rest x)
  (?
	(some #'string? x)
      (let args (string-concat-successive-literals x)
		(? .args
      	   `(string-concat ,@args)
	  	   args.))
	(every #'string? x)
	  (apply #'string-concat x)
;	(not (= 2 (length x)))
;      `(+ ,@x)
;	(and (some #'character? x) ; XXX would still mix with other types in vars
;		 (not (some #'integerp x)))
;      `(character+ ,@x)
;	(and (some #'integerp x)
;		 (not (some #'character? x)))
;      `(integer+ ,@x)
    `(+ ,@x)))

(mapcan-macro _
    '(- = < > <= >=)
  `((defmacro ,_ (&rest x)
  	  (?
		(some #'string? x)
      	  `(,($ 'string _) ,,@x)
	    (and (some #'character? x) ; XXX would still mix with other types in vars
		     (not (some #'integerp x)))
      	  `(,($ 'character _) ,,@x)
	    (and (some #'integerp x)
		     (not (some #'character? x)))
      	  `(,($ 'integer _) ,,@x)
        `(,_ ,,@x)))))

;; Make inliners for CHARACTER arithmetics.
(mapcan-macro _
    '(= < > <= >=)
  (with (charname ($ 'character _)
         op		  ($ '%%% _))
    `((defmacro ,charname (&rest x)
        (? (= 2 (length x))
           `(,op (%slot-value ,,x. v)
                 (%slot-value ,,.x. v))
           `(,charname ,,@x)))
      (defmacro ,($ 'integer _) (&rest x)
		`(,op ,,@x)))))

(defmacro character+ (&rest x)
  (? (= 2 (length x))
     `(code-char (%%%+ (%slot-value ,x. v)
                       (%slot-value ,.x. v)))
     `(character+ ,@x)))

(defmacro integer+ (&rest x)
  `(%%%+ ,@x))

(defmacro character- (&rest x)
  (? (= 1 (length x))
     `(code-char (%transpiler-native "(-" (%slot-value ,x. v) ")"))
     `(code-char (%%%- ,@(mapcar (fn (? (integerp _)
							            _
							            `(%slot-value ,_ v)))
                                 x)))))

(defmacro integer- (&rest x)
  (? (= 1 (length x))
     `(%transpiler-native "(-" ,x. ")")
     `(%%%- ,@x)))
