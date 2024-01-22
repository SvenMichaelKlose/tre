(fn %character (code)
  (= this.__class ,(convert-identifier '%character)
     this.__code  code)
  this)

(fn character? (x)
  (& (object? x)
     x.__class
     (%%%== x.__class ,(convert-identifier '%character))))

(fn code-char (x)    (new %character x))
(fn char-code (x)    x.__code)
(fn char-string (x)  (*string.from-char-code (char-code x)))

(fn char (seq idx)
-  (& (%%%< idx seq.length)
-     (code-char (seq.char-code-at idx))))
