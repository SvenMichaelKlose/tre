(fn token-is-quote? (x)
  (in? x :quote :backquote :quasiquote :quasiquote-splice))

(fn %read-closing-parens? (x)
  (in? x :parenthesis-close :bracket-close :brace-close))

(fn special-char? (x)
  (in? x #\( #\)
         #\[ #\]
         #\{ #\}
         #\" #\' #\`
         #\, #\: #\;
         #\#))

(fn symbol-char? (x)
  (& x
     (> (char-code x) 32)
     (not (special-char? x))))

(fn skip-comment (str)
  (awhen (read-char str)
    (? (== (char-code !) 10)
       (skip-spaces str)
       (skip-comment str))))

(fn skip-spaces (str)
  (when (eql #\; (peek-char str))
    (skip-comment str))
  (when (whitespace? (peek-char str))
    (read-char str)
    (skip-spaces str)))

(fn seek-char (str)
  (skip-spaces str)
  (peek-char str))

(fn read-symbol (str)
  (with (f [0 & (symbol-char? (peek-char str))
                (. (read-char str) (f))]
         f2 [0 unless (| (not (peek-char str))
                         (eql #\| (peek-char str)))
                 (? (eql #\\ (peek-char str))
                    (progn
                      (read-char str)
                      (. (read-char str) (f2)))
                    (. (read-char str) (f2)))])
    (? (eql #\| (seek-char str))
       (progn
         (read-char str)
         (when (whitespace? (peek-char str))
           (return (list #\|)))
         (prog1 (f2)
           (!= (peek-char str)
             (? (eql #\| !)
                (read-char str)
                (error "Vertical bar '|' expected as end of symbol name instead of '~A'."
                       (string !))))))
       (unless (special-char? (seek-char str))
         (filter #'char-upcase (f))))))

(fn read-symbol-and-package (str)
  (!= (read-symbol str)
    (? (eql (peek-char str) #\:)
       (progn
         (read-char str)
         (values (| (& ! (list-string !))
                    "KEYWORD")
                 (read-symbol str)))
       (values nil !))))

(fn read-string (str)
  (with (f [0 != (read-char str)
               (unless (eql ! #\")
                 (. (? (eql ! #\\)
                       (read-char str)
                       !)
                    (f)))})
    (list-string (f))))

(fn read-comment-block (str)
  (while (not (& (eql #\| (read-char str))
                 (eql #\# (peek-char str))))
     (read-char str)))

(fn list-number? (x)
  (& (| (& .x
           (| (eql #\- x.)
              (eql #\. x.)))
        (digit-char? x.))
     (? .x
        (every [| (digit-char? _)
                  (eql #\. _)]
               .x)
        t)))

(fn read-token (str)
  (awhen (read-symbol-and-package str)
    (with ((pkg sym) !)
      (values (? (& sym
                    (not .sym)
                    (eql #\. sym.))
                 :dot
                 (? sym
                    (? (list-number? sym)
                       :number
                       :symbol)
                    (case (read-char str)
                      #\(  :parenthesis-open
                      #\)  :parenthesis-close
                      #\[  :bracket-open
                      #\]  :bracket-close
                      #\{  :brace-open
                      #\}  :brace-close
                      #\'  :quote
                      #\`  :backquote
                      #\"  :dblquote
                      #\,  (? (eql #\@ (peek-char str))
                              (& (read-char str)
                                 :quasiquote-splice)
                              :quasiquote)
                      #\#  (case (read-char str)
                             #\\  :char
                             #\x  :hexnum
                             #\'  :function
                             #\(  :array
                             #\|  (read-comment-block str)
                             (error "Invalid character after '#'."))
                      -1   :eof)))
              (| pkg *package*)
              (list-string sym)))))

(fn read-make-symbol (sym &optional (pkg *package*))
  (| (find-symbol sym pkg)
     (make-symbol sym pkg)))

(fn read-slot-value (x)
  (?
    (not x)       nil
    .x            `(slot-value ,(read-slot-value (butlast x)) ',(read-make-symbol (car (last x))))
    (string? x.)  (read-make-symbol x.)
    x.))

(fn read-symbol-or-slot-value (pkg sym)
  (!= (split #\. sym)
    (? (& .! !. (car (last !)))
       (read-slot-value !)
       (read-make-symbol sym pkg))))

(fn read-atom (str token pkg sym)
  (case token :test #'eq
    :dblquote   (read-string str)
    :char       (read-char str)
    :number     (with-stream-string s sym
                  (read-number s))
    :hexnum     (read-hex str)
    :array      (. 'array (read-cons-slot str))
    :function   `(function ,(read-expr str))
    :symbol     (read-symbol-or-slot-value pkg sym)
    (? (%read-closing-parens? token)
       (error "Unexpected closing ~A."
              (case token
                :parenthesis-close  "parenthesis"
                :brace-close        "brace"
                :bracket-close      "bracket"))
       (error "Closing bracket missing."))))

(fn read-quote (str token)
  (list (make-symbol (symbol-name token)) (read-expr str)))

(fn read-cons (str)
  (with (err [!= (stream-input-location str)
               (error "~A at line ~A, column ~A in file ~A."
                      _ (stream-location-line !)
                        (stream-location-column !)
                        (stream-location-id !))]
         f   #'((token pkg sym)
                 (unless (%read-closing-parens? token)
                   (. (case token
                        :parenthesis-open  (read-cons-slot str)
                        :bracket-open      (. 'brackets (read-cons-slot str))
                        :brace-open        (. 'braces   (read-cons-slot str))
                        (? (token-is-quote? token)
                           (read-quote str token)
                           (read-atom str token pkg sym)))
                      (!? (read-token str)
                          (with ((token pkg sym) !)
                            (? (eq :dot token)
                               (with (x                (read-expr str)
                                      (token pkg sym)  (read-token str))
                                 (| (%read-closing-parens? token)
                                    (err "Only one value allowed after dotted cons"))
                                 x)
                               (f token pkg sym)))
                          (err "Closing bracket missing")))))
         (token pkg sym) (read-token str))
    (? (eq token :dot)
       (. 'cons (read-cons str))
       (f token pkg sym))))

(fn read-cons-slot (str)
  (!= (read-cons str)
    (? (eql #\. (peek-char str))
       (progn
         (read-char str)
         (with ((token pkg sym) (read-token str))
           (read-slot-value (list ! sym))))
       !)))

(fn read-expr (str)
  (with ((token pkg sym) (read-token str))
    (case token
      nil                nil
      :eof               nil
      :parenthesis-open  (read-cons-slot str)
      :bracket-open      (. 'brackets (read-cons-slot str))
      :brace-open        (. 'braces   (read-cons-slot str))
      (? (token-is-quote? token)
         (read-quote str token)
         (read-atom str token pkg sym)))))

(fn read (&optional (str *standard-input*))
  (& (seek-char str)
     (read-expr str)))

(fn read-all (str)
  (& (seek-char str)
     (. (read str)
        (read-all str))))
