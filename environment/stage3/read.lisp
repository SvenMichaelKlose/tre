;;;;; tré – Copyright (c) 2008,2010,2012–2013 Sven Michael Klose <pixel@copei.de>

(defun token-is-quote? (x)
  (in? x 'quote 'backquote 'quasiquote 'quasiquote-splice 'accent-circonflex))

(defun %read-closing-bracket? (x)
  (in? x 'bracket-close 'square-bracket-close 'curly-bracket-close))

(defun special-char? (x)
  (in=? x #\( #\)
          #\[ #\]
          #\{ #\}
          #\' #\` #\, #\: #\; #\" #\# #\^))

(defun symbol-char? (x)
  (& (> x 32) (not (special-char? x))))

(defun skip-comment (str)
  (let c (read-char str)
	(? (in=? c 10 -1)
	   (skip-spaces str)
	   (skip-comment str))))

(defun skip-spaces (str)
  (unless (end-of-file? str)
    (let c (peek-char str)
      (when (== #\; c)
        (skip-comment str))
      (when (& (< c 33) (>= c 0))
        (read-char str)
        (skip-spaces str)))))

(defun get-symbol-0 (str)
  (let c (char-upcase (peek-char str))
    (? (== 59 c) ; #\; - vim syntax highlighting fscks up.
       (progn
         (skip-comment str)
         (get-symbol-0 str))
       (& (symbol-char? c)
          (cons (char-upcase (read-char str))
                (get-symbol-0 str))))))

(defun get-symbol (str)
  (unless (| (end-of-file? str)
	         (special-char? (peek-char str)))
    (get-symbol-0 str)))

(defun get-symbol-and-package (str)
  (skip-spaces str)
  (let sym (get-symbol str)
	(? (== (peek-char str) #\:)
	   (values (| sym t) (& (read-char str)
				            (get-symbol str)))
	   (values nil sym))))

(defun read-string-0 (str)
  (let c (read-char str)
    (unless (== c 34) ; " - vim syntax highlighting fscks up.
      (cons (? (== c #\\)
               (read-char str)
               c)
            (read-string-0 str)))))

(defun read-string (str)
  (list-string (read-string-0 str)))

(defun read-comment-block (str)
  (while (not (& (== #\| (read-char str))
			     (== #\# (peek-char str))))
	     (read-char str)
    nil))

(defun read-token (str)
  (with ((pkg sym) (get-symbol-and-package str))
	(values (? (& sym (not .sym) (== #\. sym.))
		         'dot
		       (? sym
                  (? (every [| (digit-char? _)
                               (eq #\. _)]
                            sym)
                     'number
			         'symbol)
			      (case (read-char str)
			        #\(	 'bracket-open
			        #\)	 'bracket-close
			        #\[	 'square-bracket-open
			        #\]	 'square-bracket-close
			        #\{	 'curly-bracket-open
			        #\}	 'curly-bracket-close
			        #\'	 'quote
			        #\`	 'backquote
			        #\^	 'accent-circonflex
			        #\"	 'dblquote
			        #\,	 (? (== #\@ (peek-char str))
				            (& (read-char str) 'quasiquote-splice)
				            'quasiquote)
			        #\#	(case (read-char str)
				          #\\  'char
				          #\x  'hexnum
				          #\'  'function
				          #\|  (read-comment-block str)
				          (error "Invalid character after '#'."))
			        -1	'eof)))
		     pkg sym)))

(defun read-atom (str token pkg sym)
  (case token
    'dblquote  (read-string str)
    'char      (code-char (read-char str))
    'number    (with-stream-string s (list-string sym)
                 (read-number s))
    'hexnum    (read-hex str)
	'function  `(function ,(read-expr str))
    'symbol    (make-symbol (list-string sym)
						    (?
							  (not pkg)	    nil
							  (eq t pkg)	*keyword-package*
							  (make-package (list-string pkg))))
	(error "Syntax error: token ~A, sym ~A." token sym)))

(defun read-quote (str token)
  (list token (read-expr str)))

(defun read-set-listprop (str)
  (= *default-listprop* (cons (stream-in-id str) (cons (stream-in-column str) (stream-in-line str)))))

(defun read-list (str token pkg sym)
  (| token (error "Missing closing bracket."))
  (unless (%read-closing-bracket? token)
    (cons (with-temporary *default-listprop* *default-listprop*
            (case token
		      'bracket-open        (read-cons-slot str)
		      'square-bracket-open (cons 'square (read-cons-slot str))
		      'curly-bracket-open  (cons 'curly (read-cons-slot str))
		      (? (token-is-quote? token)
                 (read-quote str token)
		         (read-atom str token pkg sym))))
          (with-temporary *default-listprop* *default-listprop*
	        (with ((token pkg sym) (read-token str))
	          (? (eq 'dot token)
		         (with (x (read-expr str)
				        (token pkg sym) (read-token str))
		           (| (%read-closing-bracket? token)
			          (error "Only one value allowed after dotted cons."))
			       x)
		         (read-list str token pkg sym)))))))

(defun read-cons (str)
  (with ((token pkg sym) (read-token str))
    (unless (%read-closing-bracket? token)
	  (read-list str token pkg sym))))

(defun read-cons-slot (str)
  (read-set-listprop str)
  (with-temporary *default-listprop* *default-listprop*
    (let l (read-cons str)
	  (? (== #\. (peek-char str))
	     (& (read-char str)
		    `(slot-value ,l (quote ,(read-expr str))))
	     l))))

(defun read-expr (str)
  (with ((token pkg sym) (read-token str))
    (case token
      nil                  nil
      'eof                 nil
      'bracket-open        (read-cons-slot str)
      'square-bracket-open (cons 'square (read-cons-slot str))
      'curly-bracket-open  (cons 'curly (read-cons-slot str))
      (? (token-is-quote? token)
         (read-quote str token)
         (read-atom str token pkg sym)))))

(defun read (&optional (str *standard-input*))
  "Read expression from stream."
  (skip-spaces str)
  (unless (end-of-file? str)
	(read-expr str)))

(defun read-all (str)
  "Read all expressions from stream."
  (unless (progn
	        (skip-spaces str)
	        (end-of-file? str))
    (cons (read str) (read-all str))))
