;;;;; tré – Copyright (c) 2005–2014 Sven Michael Klose <pixel@copei.de>

(in-package :tre-core)

(defmacro alet (x &rest body)
  `(let ((! ,x))
     ,@body))

(defun peek-char (str)
  (alet (cl-peek-char nil str nil 'eof)
    (unless (eq ! 'eof)
      !)))

(defun read-char (str)
  (alet (cl-read-char str nil 'eof)
    (unless (eq ! 'eof)
      !)))

(defmacro in? (obj &rest lst)
  `(or ,@(filter #'(lambda (x) `(eq ,obj ,x)) lst)))

(defmacro in=? (obj &rest lst)
  `(or ,@(filter #'(lambda (x) `(char= ,obj ,x)) lst)))

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
  (apply #'concatenate 'string (mapcar #'string x)))

(defun whitespace? (x)
  (and (char< x (code-char 33))
       (char>= x (code-char 0))))

(defun decimal-digit? (x)
  (char<= x (code-char 0) (code-char 9)))

(defun %nondecimal-digit? (x start base)
  (<= (char-code x) start (+ start (- base 10))))

(defun nondecimal-digit? (x &key (base 10))
  (and (char< (code-char 10) (code-char base))
       (or (%nondecimal-digit? x #\a base)
           (%nondecimal-digit? x #\A base))))

(defun digit-char? (c &key (base 10))
  (and (character? c)
       (or (decimal-digit? c)
           (nondecimal-digit? c :base base))))

(load "environment/stage2/while.lisp")

(defun split (obj seq &key (test #'eql) (include? nil))
  (and seq
       (alet (position obj seq :test test)
         (? !
            (cons (subseq seq 0 (? include? (+ 1 !) !))
                  (split obj (subseq seq (+ 1 !)) :test test :include? include?))
            (list seq)))))

(defun digit-number (x)
  (- x (char-code #\0)))

(defmacro awhen (x &rest body)
  `(alet ,x
     (when !
       ,@body)))

(defun peek-digit (str)
  (awhen (peek-char str)
    (and (digit-char? !) !)))

(defun peek-dot (str)
  (awhen (peek-char str)
    (char= #\. !)))

(defun read-decimal-places-0 (str v s)
  (? (peek-digit str)
     (read-decimal-places-0 str (+ v (* s (digit-number (read-char str)))) (/ s 10))
     v))

(defun read-decimal-places (&optional (str *standard-input*))
  (and (awhen (peek-char str)
         (digit-char? !))
     (read-decimal-places-0 str 0 0.1)))

(defun read-integer-0 (str v)
  (? (peek-digit str)
     (read-integer-0 str (+ (* v 10) (digit-number (read-char str))))
     v))

(defun read-integer (&optional (str *standard-input*))
  (and (peek-digit str)
     (read-integer-0 str 0)))

(defun read-number (&optional (str *standard-input*))
  (* (? (char= #\- (peek-char str))
        (progn
          (read-char str)
          -1)
        1)
     (+ (read-integer str)
        (or (and (peek-dot str)
              (read-char str)
              (read-decimal-places str))
           0))))

(defmacro with-stream-string (str x &body body)
  `(let ((,str (make-string-input-stream ,x)))
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
  (and (char> x (code-char 32))
       (not (special-char? x))))

(defun skip-comment (str)
  (let-when c (read-char str)
	(? (char= c (code-char 10))
	   (skip-spaces str)
	   (skip-comment str))))

(defun skip-spaces (str)
 (let-when c (peek-char str)
   (when (char= #\; c)
     (skip-comment str))
   (when (whitespace? c)
     (read-char str)
     (skip-spaces str))))

(defun get-symbol-0 (str)
  (let ((c (char-upcase (peek-char str))))
    (? (char= #\; c)
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
	(? (char= (peek-char str) #\:)
	   (values (or sym t) (and (read-char str)
				               (get-symbol str)))
	   (values nil sym))))

(defun read-string-0 (str)
  (let ((c (read-char str)))
    (unless (char= c #\")
      (cons (? (char= c #\\)
               (read-char str)
               c)
         (read-string-0 str)))))

(defun read-string (str)
  (list-string (read-string-0 str)))

(defun read-comment-block (str)
  (while (not (and (char= #\| (read-char str))
			       (char= #\# (peek-char str))))
	     (read-char str)
    nil))

(defun list-number? (x)
  (and (or (and (cdr x)
                (or (char= #\- (car x))
                    (char= #\. (car x))))
           (digit-char? (car x)))
       (? (cdr x)
          (every #'(lambda (_)
                     (or (digit-char? _)
                         (char= #\. _)))
                 (cdr x))
          t)))

(defun read-token (str)
  (multiple-value-bind (pkg sym) (get-symbol-and-package str)
	(values (? (and sym
                    (not (cdr sym))
                    (char= #\. (car sym)))
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
			        (#\,	 (? (char= #\@ (peek-char str))
				                (and (read-char str) 'quasiquote-splice)
				                'quasiquote))
			        (#\#	(case (read-char str)
				              (#\\  'char)
				              (#\x  'hexnum)
				              (#\'  'function)
				              (#\|  (read-comment-block str))
				              (t    (error "Invalid character after '#'."))))
			        (-1	'eof))))
		     pkg sym)))

(defun read-slot-value (x)
  (? x
     (? (cdr x)
        `(slot-value ,(read-slot-value (butlast x)) ',(intern (car (last x)) :tre))
        (? (string? (car x))
           (intern (car x) :tre)
           (car x)))))

(defun read-symbol-or-slot-value (sym pkg)
  (alet (filter #'(lambda (_)
                    (and _ (list-string _)))
                (split #\. sym :test #'char=))
    (? (and (cdr !) (car !) (car (last !)))
       (read-slot-value !)
       (alet (intern (list-string sym) :tre)
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
    (hexnum    (error "Reading hexadecimals is not supported by the early reader."))
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
               (let ((x (read-expr str)))
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
    (? (char= #\. (peek-char str))
       (progn
         (read-char str)
         (multiple-value-bind (token pkg sym) (read-token str)
           token pkg
           (read-slot-value (list ! (list-string sym)))))
       !)))

(defun read-expr (str)
  (multiple-value-bind (token pkg sym) (read-token str)
    (case token
      (nil                  nil)
      (eof                  nil)
      (bracket-open         (read-cons-slot str))
      (square-bracket-open  (cons 'square (read-cons-slot str)))
      (curly-bracket-open   (cons 'curly (read-cons-slot str)))
      (t (? (token-is-quote? token)
            (read-quote str token)
            (read-atom str token pkg sym))))))

(defun read (&optional (str *standard-input*))
  (skip-spaces str)
  (and (peek-char str)
	   (read-expr str)))

(defun read-all (str)
  (skip-spaces str)
  (and (peek-char str)
       (cons (read str)
             (read-all str))))
