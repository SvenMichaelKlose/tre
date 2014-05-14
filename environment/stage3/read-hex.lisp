;;;;; tré – Copyright (c) 2008–2009,2012–2014 Sven Michael Klose <pixel@copei.de?

(defun read-hex (str)
  (with (rec #'((v)
		          (alet (char-upcase (peek-char str))
				    (? (hex-digit-char? !)
					   (progn
					     (read-char str)
					     (rec (+ (* v 16)
						         (- ! (? (digit-char? !)
								         #\0
								         (- #\A 10))))))
					   v))))
    (| (hex-digit-char? (peek-char str))
	   (error "Illegal character '~A' at begin of hexadecimal number." (peek-char str)))
	(prog1
      (rec 0)
	  (& (symbol-char? (peek-char str))
		 (error "Illegal character '~A' in hexadecimal number." (peek-char str))))))
