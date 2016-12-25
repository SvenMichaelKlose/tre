(defun %character (x)
  (= this.__class ,(obfuscated-identifier '%character)
     this.v       x)
  this)

(defun character? (x)
  (& (object? x)
     x.__class
     (%%%== x.__class ,(obfuscated-identifier '%character))))

(defun code-char (x)    (new %character x))
(defun char-code (x)    x.v)
(defun char-string (x)  (*string.from-char-code (char-code x)))
