(defun token-is-quote? (x)
  (in? x 'quote 'backquote 'quasiquote 'quasiquote-splice 'accent-circonflex))

(defun %read-closing-bracket? (x)
  (in? x 'bracket-close 'square-bracket-close 'curly-bracket-close))

(defun special-char? (x)
  (in-chars? x #\( #\)
               #\[ #\]
               #\{ #\}
               #\" #\' #\`
               #\, #\: #\;
               #\# #\^))

(defun symbol-char? (x)
  (& x
     (> (char-code x) 32)
     (not (special-char? x))))

(defun skip-comment (str)
  (awhen (read-char str)
	(? (== (char-code !) 10)
	   (skip-spaces str)
	   (skip-comment str))))

(defun semicolon? (x)
  (& x (eql x #\;)))

(defun skip-spaces (str)
  (when (semicolon? (peek-char str))
    (skip-comment str))
  (when (whitespace? (peek-char str))
    (read-char str)
    (skip-spaces str)))

(defun seek-char (str)
  (skip-spaces str)
  (peek-char str))

(defun read-symbol (str)
  (with (f #'(()
                (& (symbol-char? (peek-char str))
                   (. (char-upcase (read-char str))
                      (f)))))
    (unless (special-char? (seek-char str))
      (f))))

(defun read-symbol-and-package (str)
  (alet (read-symbol str)
    (? (eql (peek-char str) #\:)
       (values (| ! *keyword-package*)
               (& (read-char str)
                  (read-symbol str)))
       (values nil !))))

(defun read-string (str)
  (with (f #'(()
                (alet (read-char str)
                  (unless (eql ! #\")
                    (. (? (eql ! #\\)
                          (read-char str)
                          !)
                       (f))))))
    (list-string (f))))

(defun read-comment-block (str)
  (while (not (& (eql #\| (read-char str))
			     (eql #\# (peek-char str))))
	     (read-char str)))

(defun list-number? (x)
  (& (| (& .x
           (| (eql #\- x.)
              (eql #\. x.)))
        (digit-char? x.))
     (? .x
        (every [| (digit-char? _)
                  (eql #\. _)]
               .x)
        t)))

(defun read-token (str)
  (awhen (read-symbol-and-package str)
    (with ((pkg sym) !)
      (values (? (& sym
                    (not .sym)
                    (eql #\. sym.))
                 'dot
                 (? sym
                    (? (list-number? sym)
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
                      #\,	 (? (eql #\@ (peek-char str))
                              (& (read-char str)
                                 'quasiquote-splice)
                              'quasiquote)
                      #\#	 (case (read-char str)
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

(defun read-symbol-or-slot-value (pkg sym)
  (alet (@ [& _ (list-string _)]
           (split #\. sym))
    (? (& .! !. (car (last !)))
       (read-slot-value !)
       (tre:make-symbol (list-string sym)
                        (?
                          (not pkg)    nil
                          (cons? pkg)  (list-string pkg)
                          pkg)))))

(defun read-atom (str token pkg sym)
  (case token :test #'eq
    'dblquote  (read-string str)
    'char      (read-char str)
    'number    (with-stream-string s (list-string sym)
                 (read-number s))
    'hexnum    (read-hex str)
	'function  `(function ,(read-expr str))
    'symbol    (read-symbol-or-slot-value pkg sym)
    (? (%read-closing-bracket? token)
       (error "~A bracket missing."
              (case token :test #'eq
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
      (? (!? (peek-char str)
             (eql #\. !))
         {(read-char str)
          (with ((token pkg sym) (read-token str))
            (read-slot-value (list ! (list-string sym))))}
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
  (& (seek-char str)
	 (read-expr str)))

(defun read-all (str)
  (& (seek-char str)
     (. (read str)
        (read-all str))))
