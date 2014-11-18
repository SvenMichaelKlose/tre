;;;;; tré – Copyright (c) 2005–2014 Sven Michael Klose <pixel@copei.de>

(defmacro in? (obj &rest lst)
  `(or ,@(filter #'(lambda (x) `(eq ,obj ,x)) lst)))

(defmacro in=? (obj &rest lst)
  `(or ,@(filter #'(lambda (x) `(eql ,obj ,x)) lst)))

(defmacro let-when (x expr &body body)
  `(let ((,x ,expr))
	 (when ,x
	   ,@body)))

(defmacro with-gensym (x &rest body)
  `(let ((,x (gensym)))
     ,@body))

(defmacro with-temporary (place val &body body)
  (with-gensym old-val
    `(let ((,old-val ,place))
       (setf ,place ,val)
       (prog1
         (progn
           ,@body)
         (setf ,place ,old-val)))))

(defmacro with-temporaries (lst &body body)
  (or lst (error "Assignment list expected."))
  `(with-temporary ,(car lst) ,(cadr lst)
     ,@(? (cddr lst)
          `((with-temporaries ,(cddr lst) ,@body))
          body)))

(defun list-string (x)
  (apply #'concatenate 'string x))

(defun whitespace? (x)
  (and (< x 33)
       (>= x 0)))

(defun decimal-digit? (x)
  (<= x 0 9))

(defun %nondecimal-digit? (x start base)
  (<= x start (+ start (- base 10))))

(defun nondecimal-digit? (x &key (base 10))
  (and (< 10 base)
       (or (%nondecimal-digit? x #\a base)
           (%nondecimal-digit? x #\A base))))

(defun digit-char? (c &key (base 10))
  (and (character? c)
       (or (decimal-digit? c)
           (nondecimal-digit? c :base base))))

(load "environment/stage2/while.lisp")

(defmacro alet (x &rest body)
  `(let ((! ,x))
     ,@body))

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
  (and (> x 32)
       (not (special-char? x))))

(defun skip-comment (str)
  (let-when c (read-char str)
	(? (in=? c 10)
	   (skip-spaces str)
	   (skip-comment str))))

(defun skip-spaces (str)
 (let-when c (peek-char str)
   (when (eql #\; c)
     (skip-comment str))
   (when (whitespace? c)
     (read-char str)
     (skip-spaces str))))

(defun get-symbol-0 (str)
  (let ((c (char-upcase (peek-char str))))
    (? (equal #\; c)
       (progn
         (skip-comment str)
         (get-symbol-0 str))
       (and (symbol-char? c)
          (cons (char-upcase (read-char str))
                (get-symbol-0 str))))))

(defun get-symbol (str)
  (let-when c (peek-char str)
    (unless (special-char? c)
      (get-symbol-0 str))))

(defun get-symbol-and-package (str)
  (skip-spaces str)
  (let ((sym (get-symbol str)))
	(? (eql (peek-char str) #\:)
	   (values (or sym t) (and (read-char str)
				            (get-symbol str)))
	   (values nil sym))))

(defun read-string-0 (str)
  (let ((c (read-char str)))
    (unless (eql c #\")
      (cons (? (eql c #\\)
               (read-char str)
               c)
         (read-string-0 str)))))

(defun read-string (str)
  (list-string (read-string-0 str)))

(defun read-comment-block (str)
  (while (not (and (eql #\| (read-char str))
			     (eql #\# (peek-char str))))
	     (read-char str)
    nil))

(defun list-number? (x)
  (and (or (and (cdr x)
           (or (eql #\- (car x))
              (eql #\. (car x))))
        (digit-char? (car x)))
     (? (cdr x)
        (every #'(lambda (_)
                   (or (digit-char? _)
                       (eql #\. _)))
               (cdr x))
        t)))

(defun read-token (str)
  (multiple-value-bind (pkg sym) (get-symbol-and-package str)
	(values (? (and sym
                  (not (cdr sym))
                  (eql #\. (car sym)))
		       'dot
		       (? sym
                  (? (list-number? sym)
                     'number
			         'symbol)
			      (case (read-char str)
			        (#\(	 'bracket-open)
			        (#\)	 'bracket-close)
			        (#\[	 'square-bracket-open)
			        (#\]	 'square-bracket-close)
			        (#\{	 'curly-bracket-open)
			        (#\}	 'curly-bracket-close)
			        (#\'	 'quote)
			        (#\`	 'backquote)
			        (#\^	 'accent-circonflex)
			        (#\"	 'dblquote)
			        (#\,	 (? (eql #\@ (peek-char str))
				                (and (read-char str) 'quasiquote-splice)
				                'quasiquote))
			        (#\#	(case (read-char str)
				              (#\\  'char)
				              (#\x  'hexnum)
				              (#\'  'function)
				              (#\|  (read-comment-block str))
				              (t    (error "Invalid character after '#'."))))
			        (-1	'eof)))
		     pkg sym))))

(defun read-slot-value (x)
  (? x
     (? (cdr x)
        `(slot-value ,(read-slot-value (butlast x)) ',(make-symbol (car (last x))))
        (? (string? (car x))
           (make-symbol (car x))
           (car x)))))

(defun read-symbol-or-slot-value (sym pkg)
  (alet (filter #'(lambda (_)
                    (and _ (list-string _)))
                (split #\. sym))
    (? (and (cdr !) (car !) (car (last !)))
       (read-slot-value !)
       (alet (make-symbol (list-string sym))
         (?
           (not pkg)   !
           (eq t pkg)  (make-keyword !)
           (error "Cannot read package names in early reader."))))))

(defun read-atom (str token pkg sym)
  (case token
    (dblquote  (read-string str))
    (char      (code-char (read-char str)))
    (number    (with-stream-string s (list-string sym)
                 (read-number s)))
    (hexnum    (read-hex str))
	(function  `(function ,(read-expr str)))
    (symbol    (read-symbol-or-slot-value sym pkg))
	(t (error "Syntax error: token ~A, sym ~A." token sym))))

(defun read-quote (str token)
  (list token (read-expr str)))

(defun read-list (str token pkg sym)
  (or token (error "Missing closing bracket."))
  (unless (%read-closing-bracket? token)
    (cons (case token
            (bracket-open        (read-cons-slot str))
            (square-bracket-open (cons 'square (read-cons-slot str)))
            (curly-bracket-open  (cons 'curly (read-cons-slot str)))
            (t (? (token-is-quote? token)
                 (read-quote str token)
                 (read-atom str token pkg sym))))
          (multiple-value-bind (token pkg sym) (read-token str)
            (? (eq 'dot token)
               (let ((x                (read-expr str)))
                 (multiple-value-bind (token pkg sym)  (read-token str)
                   pkg sym
                   (or (%read-closing-bracket? token)
                       (error "Only one value allowed after dotted cons."))
                   x))
               (read-list str token pkg sym))))))

(defun read-cons (str)
  (multiple-value-bind (token pkg sym) (read-token str)
    (? (eq token 'dot)
       (cons 'cons (read-cons str))
	   (read-list str token pkg sym))))

(defun read-cons-slot (str)
  (alet (read-cons str)
    (? (eql #\. (peek-char str))
       (progn
         (read-char str)
         (multiple-value-bind (token pkg sym) (read-token str)
           token pkg
           (read-slot-value (list ! (list-string sym)))))
       !)))

(defun read-expr (str)
  (multiple-value-bind (token pkg sym) (read-token str)
    (case token
      (nil                  nil
      (eof                  nil
      (bracket-open         (read-cons-slot str)
      (square-bracket-open  (cons 'square (read-cons-slot str))
      (curly-bracket-open   (cons 'curly (read-cons-slot str))
      (t (? (token-is-quote? token)
            (read-quote str token)
            (read-atom str token pkg sym)))))

(defun read (&optional (str *standard-input*))
  (skip-spaces str)
  (and (peek-char str)
	 (read-expr str)))

(defun read-all (str)
  (skip-spaces str)
  (and (peek-char str)
       (cons (read str)
             (read-all str))))
