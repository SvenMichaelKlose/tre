(fn %character (x)
  (= this.__class ,(convert-identifier '%character)
     this.v       x)
  this)

(fn character? (x)
  (& (object? x)
     x.__class
     (%%%== x.__class ,(convert-identifier '%character))))

(fn code-char (x)    (new %character x))
(fn char-code (x)    x.v)
(fn char-string (x)  (*string.from-char-code (char-code x)))
