;;;; TRE environment
;;;; Copyright (c) 2008,2010 Sven Klose <pixel@copei.de>

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
		(values (or sym
					t)
				(and (read-char str)
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

(defun read-comment-block (str)
  (loop
	(if (and (= #\| (read-char str))
			 (= #\# (read-char str)))
		(read-token str))))

(defun read-token (str)
  (with ((pkg sym) (get-symbol-and-package str))
	(values (if (and sym
					 (not .sym)
			         (= #\. sym.))
		        'dot
		        (if sym
			        'symbol
			        (case (read-char str)
			          #\(	'bracket-open
			          #\)	'bracket-close
			          #\'	'quote
			          #\`	'backquote
			          #\"	'dblquote
			          #\,	(if (= #\@ (peek-char str))
						        (and (read-char str)
							         'quasiquote-splice)
						        'quasiquote)
			          #\#	(case (read-char str)
					          #\\	'char
					          #\x	'hexnum
					          #\'	'function
					          #\|	(read-comment-block str)
					          (error "invalid character after '#'"))
			          -1	'eof)))
		     pkg sym)))

(defun read-atom (str token pkg sym)
  (case token
    'dblquote (get-string str)
    'char     (code-char (read-char str))
    'hexnum   (read-hex str)
	'function `(function ,(read-expr str))
    'symbol   (make-symbol (list-string sym)
						   (if
							 (not pkg)	nil
							 (eq t pkg)	*keyword-package*
							 (make-package (list-string pkg))))
	(error "syntax error: token ~A, sym ~A" token sym)))

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
			  'dot		(with (x (read-expr str)
							   (token pkg sym) (read-token str))
					      (unless (eq 'bracket-close token)
						    (error "only one value allowed after dotted cons"))
					      x)
			  (read-list str token pkg sym))))))
			
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

(defun read-all (str)
  "Read many toplevel expressions from stream."
  (unless (progn
			(skip-spaces str)
			(end-of-file str))
    (cons (read str)
		  (read-all str))))
