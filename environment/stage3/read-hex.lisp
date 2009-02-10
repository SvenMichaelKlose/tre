;;;; TRE tree processor environment
;;;; Copyright (c) 2008-2009 Sven Klose <pixel@copei.de?

(defun hex-digit-char-p (x)
  (or (digit-char-p x)
      (and (>= c #\A) (<= c #\F))
      (and (>= c #\a) (<= c #\f))))

(defun read-hex (str)
  (with (rec #'((&optional (v 0) (n 0))
		         (with (c (char-upcase (peek-char str)))
				   (if (hex-digit-char-p c)
					   (progn
						    (read-char str)
					        (rec (+ (* v 16)
							        (- c (if (digit-char-p c)
									         10
									         (- #\A 10))))))
					   v))))
    (unless (hex-digit-char-p (peek-char str))
	  (error "illegal character '~A' at begin of hexadecimal number" (string (code-char (peek-char str)))))
	(with (v (rec))
	  (when (is-symchar? (peek-char str))
		(error "illegal character '~A' in hexadecimal number" (string (code-char (peek-char str)))))
	  v)))
