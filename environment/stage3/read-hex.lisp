;;;;; tré – Copyright (c) 2008–2009,2012 Sven Michael Klose <pixel@copei.de?

(defun hex-digit-char-p (x)
  (| (digit-char-p x)
     (& (>= x #\A) (<= x #\F))
     (& (>= x #\a) (<= x #\f))))

(defun read-hex (str)
  (with (rec #'((&optional (v 0) (n 0))
		         (with (c (char-upcase (peek-char str)))
				   (? (hex-digit-char-p c)
					  (progn
					    (read-char str)
					    (rec (+ (* v 16)
						        (- c (? (digit-char-p c)
								        10
								        (- #\A 10))))))
					  v))))
    (| (hex-digit-char-p (peek-char str))
	   (error "illegal character '~A' at begin of hexadecimal number" (peek-char str)))
	(prog1
      (rec)
	  (& (symbol-char? (peek-char str))
		 (error "illegal character '~A' in hexadecimal number" (peek-char str))))))
