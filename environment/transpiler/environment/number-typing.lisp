(defmacro + (&rest x)       (opt-string-concat x '+))
(defmacro - (&rest x)       `(%%%- ,@x))
(defmacro * (&rest x)       `(%%%* ,@x))
(defmacro / (&rest x)       `(%%%/ ,@x))
(defmacro mod (&rest x)     `(%%%mod ,@x))
(defmacro number+ (&rest x) `(%%%+ ,@x))

(defmacro == (a b) `(%%%== ,a ,b))
(defmacro < (a b)  `(%%%< ,a ,b))
(defmacro > (a b)  `(%%%> ,a ,b))
(defmacro <= (a b) `(%%%<= ,a ,b))
(defmacro >= (a b) `(%%%>= ,a ,b))

(defmacro << (a b)      `(%%%<< ,a ,b))
(defmacro >> (a b)      `(%%%>> ,a ,b))
(defmacro bit-or (a b)  `(%%%bit-or ,a ,b))
(defmacro bit-and (a b) `(%%%bit-and ,a ,b))

(defmacro integer- (&rest x)
  (? .x
     `(%%%- ,@x)
     `(%%native "(-" ,x. ")")))

(defmacro def-integer-op (op)
  `(defmacro ,($ 'integer op) (a b)
     `(,($ '%%% op) ,,a ,,b)))

(def-integer-op +)
(def-integer-op ==)
(def-integer-op <)
(def-integer-op >)
(def-integer-op <=)
(def-integer-op >=)
