(var *characters* (make-array))

(fn character? (x)
  (is_a x "__character"))

(fn code-char (x)
  (declare type number x)
  (new __character x))

(fn char-code (x)
  (declare type character x)
  x.v)

(fn char-string (x)
  (declare type character x)
  (chr x.v))
