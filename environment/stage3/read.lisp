;;;; TRE tree processor environment
;;;; Copyright (c) 2008 Sven Klose <pixel@copei.de?
;;;;
;;;; Expression reader.

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

(defun token-is-quote? (x)
  (in? x 'quote 'backquote 'quasiquote 'quasiquote-splice))

(defun is-special-char? (x)
  (in=? x #\( #\) #\' #\` #\, #\: #\; #\" #\#))

(defun is-symchar? (x)
  (and (> x 32)
	   (not (in=? x #\( #\) #\' #\` #\, #\: #\;))))

(defun skip-comment (str)
  (with (c (read-char str))
	(if (in=? c 10 -1)
	    (skip-spaces str)
	    (skip-comment str))))

(defun skip-spaces (str)
  (unless (end-of-file str)
    (with (c (peek-char str))
      (when (= #\; c)
	    (skip-comment str))
	  (when (and (< c 33)
			     (>= c 0))
	    (read-char str)
	    (skip-spaces str)))))

(defun get-symbol (str)
  (with (rec #'(()
				 (with (c (char-upcase (peek-char str)))
                   (if (= 59 c) ; #\; - vim syntax highlighting fscks up.
                       (progn
						 (skip-comment str)
						 (rec))
                       (when (is-symchar? c)
                         (cons (char-upcase (read-char str))
                               (rec)))))))
  (unless (or (end-of-file str)
			  (is-special-char? (peek-char str)))
    (rec))))

(defun get-symbol-and-package (str)
  (skip-spaces str)
  (with (sym (get-symbol str))
	(if (= (peek-char str) #\:)
		(values (string-list "keyword") (and (read-char str)
											 (get-symbol str)))
		(values nil sym))))

(defun get-string (str)
  (with (rec #'(()
  				 (with (c (read-char str))
	               (unless (= c 34) ; " - vim syntax highlighting fscks up.
	                 (when (= c #\\)
		               (setf c (read-char str)))
	                 (cons c
			               (rec))))))
	(list-string (rec))))

(defun read-token (str)
  (with ((pkg sym) (get-symbol-and-package str))
	(values (if (and sym
					 (not (cdr sym))
			         (= #\. (car sym)))
		        'dot
		        (if sym
			        'symbol
			        (case (read-char str)
			          (#\(	'bracket-open)
			          (#\)	'bracket-close)
			          (#\'	'quote)
			          (#\`	'backquote)
			          (#\"	'dblquote)
			          (#\,	(if (= #\@ (peek-char str))
						        (and (read-char str)
							         'quasiquote-splice)
						        'quasiquote))
			          (#\#	(case (read-char str)
					          (#\\	'char)
					          (#\x	'hexnum)
					          (#\'	'function)
					          (t	(error "invalid character after '#'"))))
			          (-1	'eof))))
		     pkg sym)))

(defun read-atom (str token pkg sym)
  (case token
    ('dblquote (get-string str))
    ('char     (code-char (read-char str)))
    ('hexnum   (read-hex str))
	('function `(function ,(read-expr str)))
    ('symbol   (make-symbol (list-string sym) (and pkg *keyword-package*)))
	(t		   (error "syntax error: token ~A, sym ~A" token sym))))

(defun read-quote (str token)
  (list token (read-expr str)))

(defun read-list (str token pkg sym)
  (unless token
	(error "missing closing bracket"))
  (unless (eq 'bracket-close token)
    (cons (if
			(token-is-quote? token)
			  (read-quote str token)
			(eq 'bracket-open token)
			  (with ((token pkg sym) (read-token str))
				(read-list str token pkg sym))
			(read-atom str token pkg sym))
		  (with ((token pkg sym) (read-token str))
		    (case token
			  ('dot		(with (x (read-expr str)
							   (token pkg sym) (read-token str))
					      (unless (eq 'bracket-close token)
						    (error "only one value allowed after dotted cons"))
					      x))
			  (t		(read-list str token pkg sym)))))))
			
(defun read-expr (str)
  (with ((token pkg sym) (read-token str))
	(unless (or (not token)
				(eq 'eof token))
	  (if (token-is-quote? token)
		  (read-quote str token)
		  (if (not (eq 'bracket-open token))
			  (read-atom str token pkg sym)
			  (with ((token pkg sym) (read-token str))
			    (unless (eq 'bracket-close token)
				  (read-list str token pkg sym))))))))

(defun read (&optional (str *standard-input*))
  "Read expression from stream."
  (skip-spaces str)
  (unless (end-of-file str)
	(read-expr str)))

(defun read-many (str)
  "Read many toplevel expressions from stream."
  (with (x nil)
    (while (not (end-of-file str))
           (reverse x)
      (awhen (read str)
        (push ! x)))))

(defun read-file (name)
  "Read one expression from file."
  (with-open-file in (open name :direction 'input)
	(read in)))
