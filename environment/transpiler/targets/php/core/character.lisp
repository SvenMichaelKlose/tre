(fn character? (x)
  (is_a x "__character"))

(fn code-char (x)
  (new __character x))

(fn char-code (x)
  x.v)

(fn char-string (x)
  (chr x.v))

(fn char (seq idx)
   (when (%%%< idx (strlen seq))
     (code-char (ord (substr seq idx 1)))))
