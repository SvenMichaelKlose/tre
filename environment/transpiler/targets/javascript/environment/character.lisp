;;;;; tré – Copyright (c) 2008-2009,2011–2013 Sven Michael Klose <pixel@copei.de>

(dont-inline %character from-char-code)
(dont-obfuscate from-char-code)

(defun %character (x)
  (= this.__class ,(transpiler-obfuscated-symbol-string *transpiler* '%character)
     this.v       (%wrap-char-number x))
  this)

(defun character? (x)
  (& (object? x)
     x.__class
     (%%%== x.__class ,(transpiler-obfuscated-symbol-string *transpiler* '%character))))

(defun code-char (x)   (new %character x))
(defun char-code (x)   x.v)
(defun char-string (x) (*string.from-char-code (char-code x)))
