; tré – Copyright (c) 2008–2016 Sven Michael Klose <pixel@hugbox.org>

(defmacro + (&rest x)       (opt-string-concat x '+))
(defmacro - (&rest x)       `(%%%- ,@x))
(defmacro * (&rest x)       `(%%%* ,@x))
(defmacro / (&rest x)       `(%%%/ ,@x))
(defmacro mod (&rest x)     `(%%%mod ,@x))
(defmacro number+ (&rest x) `(%%%+ ,@x))

;(defmacro < (&rest x)       `(%%%< ,@x)) ; TODO: Native operators are binary! Split them up.
;(defmacro > (&rest x)       `(%%%> ,@x))
;(defmacro <= (&rest x)      `(%%%<= ,@x))
;(defmacro >= (&rest x)      `(%%%>= ,@x))

(defmacro integer- (&rest x)
  (? .x
     `(%%%- ,@x)
     `(%%native "(-" ,x. ")")))

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
     (error "==: Unexpected STRING."))
  (& (some #'character? x)
     (error "==: Unexpected CHARACTER."))
  `(%%%== ,@x))
