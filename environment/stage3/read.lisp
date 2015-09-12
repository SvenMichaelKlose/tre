; tré – Copyright (c) 2008,2010,2012–2015 Sven Michael Klose <pixel@copei.de>

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
  (& (> x 32)
     (not (special-char? x))))

(defun skip-comment (str)
  (let-when c (read-char str)
	(? (in=? c 10)
	   (skip-spaces str)
	   (skip-comment str))))

(defun skip-spaces (str)
 (let-when c (peek-char str)
   (when (== #\; c)
     (skip-comment str))
   (when (whitespace? c)
     (read-char str)
     (skip-spaces str))))

(defun get-symbol-0 (str)
  (let c (char-upcase (peek-char str))
    (? (== #\; c)
       (progn
         (skip-comment str)
         (get-symbol-0 str))
       (& (symbol-char? c)
          (. (char-upcase (read-char str))
             (get-symbol-0 str))))))

(defun get-symbol (str)
  (let-when c (peek-char str)
    (unless (special-char? c)
      (get-symbol-0 str))))

(defun get-symbol-and-package (str)
  (skip-spaces str)
  (let sym (get-symbol str)
	(awhen (peek-char str)
	  (? (== ! #\:)
	     (values (| sym t) (& (read-char str)
				              (get-symbol str)))
	     (values nil sym)))))

(defun read-string-0 (str)
  (let c (read-char str)
    (unless (== c #\")
      (. (? (== c #\\)
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

(defun list-number? (x)
  (& (| (& .x
           (| (== #\- x.)
              (== #\. x.)))
        (digit-char? x.))
     (? .x
        (every [| (digit-char? _)
                  (== #\. _)]
               .x)
        t)))

(defun read-token (str)
  (awhen (get-symbol-and-package str)
    (with ((pkg sym) !)
      (values (? (& sym
                    (not .sym)
                    (== #\. sym.))
                 'dot
                 (? sym
                    (? (list-number? sym)
                       'number
                       'symbol)
                    (case (read-char str) :test #'character==
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
                              (& (read-char str)
                                 'quasiquote-splice)
                              'quasiquote)
                      #\#	 (case (read-char str) :test #'character==
                             #\\  'char
                             #\x  'hexnum
                             #\'  'function
                             #\|  (read-comment-block str)
                             (error "Invalid character after '#'."))
                      -1	'eof)))
              pkg sym))))

(defun read-slot-value (x)
  (? x
     (? .x
        `(slot-value ,(read-slot-value (butlast x)) ',(tre:make-symbol (car (last x))))
        (? (string? x.)
           (tre:make-symbol x.)
           x.))))

(defun read-symbol-or-slot-value (sym pkg)
  (alet (@ [& _ (list-string _)]
           (split #\. sym))
    (? (& .! !. (car (last !)))
       (read-slot-value !)
       (tre:make-symbol (list-string sym)
                        (?
                          (not pkg)  nil
                          (t? pkg)   *keyword-package*
                          (list-string pkg))))))

(defun read-atom (str token pkg sym)
  (case token :test #'eq
    'dblquote  (read-string str)
    'char      (read-char str)
    'number    (with-stream-string s (list-string sym)
                 (read-number s))
    'hexnum    (read-hex str)
	'function  `(function ,(read-expr str))
    'symbol    (read-symbol-or-slot-value sym pkg)
    (? (%read-closing-bracket? token)
       (error "~A bracket missing."
              (case token
                'bracket-close         "Round"
                'curly-bracket-close   "Curly"
                'square-bracket-close  "Square"))
	   (error "Syntax error: token ~A, sym ~A." token sym))))

(defun read-quote (str token)
  (list token (read-expr str)))

(defun read-set-listprop (str)
  (alet (stream-input-location str)
    (= *default-listprop* (. (stream-location-id !)
                             (. (memorized-number (stream-location-column !))
                                (memorized-number (stream-location-line !)))))))

(defun read-cons (str)
  (with (loc    (stream-input-location str)
         line   (stream-location-line loc)
         column (stream-location-column loc)
         file   (stream-location-id loc)
         err [error "~A in form starting at line ~A, column ~A in file ~A."
                    _ line column file]
         f #'((token pkg sym)
                (unless (%read-closing-bracket? token)
                  (. (with-temporary *default-listprop* *default-listprop*
                     (case token :test #'eq
                       'bracket-open        (read-cons-slot str)
                       'square-bracket-open (. 'square (read-cons-slot str))
                       'curly-bracket-open  (. 'curly (read-cons-slot str))
                       (? (token-is-quote? token)
                          (read-quote str token)
                          (read-atom str token pkg sym))))
                     (with-temporary *default-listprop* *default-listprop*
                      (!? (read-token str)
                          (with ((token pkg sym) !)
                            (? (eq 'dot token)
                                (with (x                (read-expr str)
                                       (token pkg sym)  (read-token str))
                                  (| (%read-closing-bracket? token)
                                     (err "Only one value allowed after dotted cons."))
                                  x)
                                (f token pkg sym)))
                          (err "Closing bracket missing.")))))))
  (with ((token pkg sym) (read-token str))
    (? (eq token 'dot)
       (. 'cons (read-cons str))
	   (f token pkg sym)))))

(defun read-cons-slot (str)
  (read-set-listprop str)
  (with-temporary *default-listprop* *default-listprop*
    (alet (read-cons str)
      (? (== #\. (peek-char str))
         (progn
           (read-char str)
           (with ((token pkg sym) (read-token str))
             (read-slot-value (list ! (list-string sym)))))
         !))))

(defun read-expr (str)
  (with ((token pkg sym) (read-token str))
    (case token :test #'eq
      nil                   nil
      'eof                  nil
      'bracket-open         (read-cons-slot str)
      'square-bracket-open  (. 'square (read-cons-slot str))
      'curly-bracket-open   (. 'curly (read-cons-slot str))
      (? (token-is-quote? token)
         (read-quote str token)
         (read-atom str token pkg sym)))))

(defun read (&optional (str *standard-input*))
  (skip-spaces str)
  (& (peek-char str)
	 (read-expr str)))

(defun read-all (str)
  (skip-spaces str)
  (& (peek-char str)
     (. (read str)
        (read-all str))))
