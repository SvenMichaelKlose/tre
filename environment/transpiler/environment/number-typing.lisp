; tré – Copyright (c) 2008–2016 Sven Michael Klose <pixel@hugbox.org>

(defmacro + (&rest x)
  (opt-string-concat x '+))

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

(defmacro == (&rest x)
  (& (some #'string? x)
     (error "==: Unexpected string."))
  `(== ,@x))
