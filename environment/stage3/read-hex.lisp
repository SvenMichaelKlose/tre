;;;;; tré - Copyright (c) 2008-2009,2012 Sven Michael Klose <pixel@copei.de?

(defun hex-digit-char-p (x)
  (or (digit-char-p x)
      (and (>= x #\A) (<= x #\F))
      (and (>= x #\a) (<= x #\f))))

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
    (unless (hex-digit-char-p (peek-char str))
	  (error "illegal character '~A' at begin of hexadecimal number" (string (code-char (peek-char str)))))
	(prog1
      (rec)
	  (when (symbol-char? (peek-char str))
		(error "illegal character '~A' in hexadecimal number" (string (code-char (peek-char str))))))))
