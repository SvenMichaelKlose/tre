(fn token-is-quote? (x)
  (in? x :quote :backquote :quasiquote :quasiquote-splice :accent-circonflex))

(fn %read-closing-bracket? (x)
  (in? x :bracket-close :square-bracket-close :curly-bracket-close))

(fn special-char? (x)
  (in? x #\( #\)
         #\[ #\]
         #\{ #\}
         #\" #\' #\`
         #\, #\: #\;
         #\# #\^))

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
                (. (char-upcase (read-char str))
                   (f))})
    (unless (special-char? (seek-char str))
      (f))))

(fn read-symbol-and-package (str)
  (alet (read-symbol str)
    (? (eql (peek-char str) #\:)
       {(read-char str)
        (values (| (& ! (list-string !))
                   *keyword-package*)
                (read-symbol str))}
       (values nil !))))

(fn read-string (str)
  (with (f [0 alet (read-char str)
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
                      #\(  :bracket-open
                      #\)  :bracket-close
                      #\[  :square-bracket-open
                      #\]  :square-bracket-close
                      #\{  :curly-bracket-open
                      #\}  :curly-bracket-close
                      #\'  :quote
                      #\`  :backquote
                      #\^  :accent-circonflex
                      #\"  :dblquote
                      #\,  (? (eql #\@ (peek-char str))
                              (& (read-char str)
                                 :quasiquote-splice)
                              :quasiquote)
                      #\#  (case (read-char str)
                             #\\  :char
                             #\x  :hexnum
                             #\'  :function
                             #\|  (read-comment-block str)
                             (error "Invalid character after '#'."))
                      -1   :eof)))
              pkg
              (list-string sym)))))

(fn read-slot-value (x)
  (?
    (not x)       nil
    .x            `(slot-value ,(read-slot-value (butlast x)) ',(make-symbol (car (last x)) "TRE"))
    (string? x.)  (make-symbol x.)
    x.))

(fn read-symbol-or-slot-value (pkg sym)
  (alet (split #\. sym)
    (? (& .! !. (car (last !)))
       (read-slot-value !)
       (make-symbol sym pkg))))

(fn read-atom (str token pkg sym)
  (case token :test #'eq
    :dblquote  (read-string str)
    :char      (read-char str)
    :number    (with-stream-string s sym
                 (read-number s))
    :hexnum    (read-hex str)
    :function  `(function ,(read-expr str))
    :symbol    (read-symbol-or-slot-value pkg sym)
    (? (%read-closing-bracket? token)
       (error "Unexpected closing ~A bracket."
              (case token
                :bracket-close         "round"
                :curly-bracket-close   "curly"
                :square-bracket-close  "square"))
       (error "Closing bracket missing."))))

(fn read-quote (str token)
  (list (make-symbol (symbol-name token)) (read-expr str)))

(fn read-cons (str)
  (with (err [alet (stream-input-location str)
               (error "~A at line ~A, column ~A in file ~A."
                      _ (stream-location-line !)
                        (stream-location-column !)
                        (stream-location-id !))]
         f   #'((token pkg sym)
                 (unless (%read-closing-bracket? token)
                   (. (case token
                        :bracket-open        (read-cons-slot str)
                        :square-bracket-open (. 'square (read-cons-slot str))
                        :curly-bracket-open  (. 'curly (read-cons-slot str))
                        (? (token-is-quote? token)
                           (read-quote str token)
                           (read-atom str token pkg sym)))
                      (!? (read-token str)
                          (with ((token pkg sym) !)
                            (? (eq :dot token)
                               (with (x                (read-expr str)
                                      (token pkg sym)  (read-token str))
                                 (| (%read-closing-bracket? token)
                                    (err "Only one value allowed after dotted cons"))
                                 x)
                               (f token pkg sym)))
                          (err "Closing bracket missing")))))
         (token pkg sym) (read-token str))
    (? (eq token :dot)
       (. 'cons (read-cons str))
       (f token pkg sym))))

(fn read-cons-slot (str)
  (alet (read-cons str)
    (? (eql #\. (peek-char str))
       (progn
         (read-char str)
         (with ((token pkg sym) (read-token str))
           (read-slot-value (list ! sym))))
       !)))

(fn read-expr (str)
  (with ((token pkg sym) (read-token str))
    (case token
      nil                   nil
      :eof                  nil
      :bracket-open         (read-cons-slot str)
      :square-bracket-open  (. 'square (read-cons-slot str))
      :curly-bracket-open   (. 'curly (read-cons-slot str))
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
