; tré – Copyright (c) 2008–2015 Sven Michael Klose <pixel@copei.de>

(defmacro + (&rest x)
  (opt-string-concat x '+))

(defmacro character+ (&rest x)
  (? (== 2 (length x))
     `(code-char (%%%+ (slot-value ,x. 'v)
                       (slot-value ,.x. 'v)))
     `(character+ ,@x)))

(defmacro character- (&rest x)
  `(code-char ,(? .x
                  `(%%%- ,@(@ [? (integer? _)
                                 _
                                 `(slot-value ,_ 'v)]
                              x))
                  `(%%native "(-" (slot-value ,x. 'v) ")"))))

(defmacro integer- (&rest x)
  (? .x
     `(%%%- ,@x)
     `(%%native "(-" ,x. ")")))

(defmacro integer1+ (x)
  `(%%%+ ,x 1))

(defmacro integer1- (x)
  `(%%%- ,x 1))

(defmacro def-integer-op (op)
  `(defmacro ,($ 'integer op) (&rest x)
     `(,($ '%%% op) ,,@x)))

(def-integer-op +)
(def-integer-op ==)
(def-integer-op <)
(def-integer-op >)
(def-integer-op <=)
(def-integer-op >=)
