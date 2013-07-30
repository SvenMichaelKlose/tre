;;;;; tré – Copyright (c) 2008–2009,2012–2013 Sven Michael Klose <pixel@copei.de?

(defun hex-digit-char? (x)
  (| (digit-char? x)
     (& (>= x #\A) (<= x #\F))
     (& (>= x #\a) (<= x #\f))))

(defun read-hex (str)
  (with (rec #'((v)
		          (let c (char-upcase (peek-char str))
				    (? (hex-digit-char? c)
					   (progn
					     (read-char str)
					     (rec (+ (* v 16)
						         (- c (? (digit-char? c)
								         10
								         (- #\A 10))))))
					   v))))
    (| (hex-digit-char? (peek-char str))
	   (error "Illegal character '~A' at begin of hexadecimal number." (peek-char str)))
	(prog1
      (rec 0)
	  (& (symbol-char? (peek-char str))
		 (error "Illegal character '~A' in hexadecimal number." (peek-char str))))))
