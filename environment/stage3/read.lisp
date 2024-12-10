(fn read-peeked-char (str)
  (prog1 (stream-peeked-char str)
    (= (stream-peeked-char str) nil)))

(fn read-char-0 (str eof)
  (| (read-peeked-char str)
     (= (stream-last-char str) (~> (stream-fun-in str) str eof))))

(fn read-char (&optional (str *standard-input*) (eof nil))
  (%track-location (stream-input-location str) (read-char-0 str eof)))

(fn peek-char (&optional (str *standard-input*) (eof nil))
  (| (stream-peeked-char str)
     (= (stream-peeked-char str) (read-char-0 str eof))))

(fn read-chars (in num &optional (eof nil))
  (list-string (@n [read-char in eof] num)))

(fn read-file (name &optional (eof nil))
  (with-open-file in-stream (open name :direction 'input)
    (read-all in-stream eof)))

(fn read-hex (str &optional (eof nil))
  (with (f [!? (& (peek-char str)
                  (!= (char-upcase (peek-char str eof))
                    (& (hex-digit? !)
                       !)))
               (progn
                 (read-char str eof)
                 (f (number+ (* _ 16)
                             (- (char-code !)
                                (? (digit? !)
                                   (char-code #\0)
                                   (- (char-code #\A) 10))))))
               _])
    (| (hex-digit? (peek-char str eof))
       (error "Illegal character '~A' at begin of hexadecimal number."
              (peek-char str eof)))
    (prog1
      (f 0)
      (& (symbol-char? (peek-char str eof))
         (error "Illegal character '~A' in hexadecimal number."
                (peek-char str eof))))))

(fn read-binary (&optional (in *standard-input*) (eof nil))
  (let n 0
    (while (!? (peek-char in eof)
               (in? ! #\0 #\1))
           n
      (= n (bit-or (<< n 1) (- (read-byte in eof) (char-code #\0)))))))

(fn peek-byte (i &optional (eof nil))
  (!= (peek-char i eof)
    (& ! (char-code !))))

(fn read-byte (i &optional (eof nil))
  (!= (read-char i eof)
    (& ! (char-code !))))

(fn read-word (i &optional (eof nil))   ; TODO: Flexible endianess.
  (!= (read-byte i eof)
    (+ (| ! (return))
       (<< (| (read-byte i eof)
              (return !))
           8))))

(fn read-dword (i &optional (eof nil))
  (!= (read-word i eof)
    (+ (| ! (return))
       (<< (| (read-word i eof)
              (return !))
           16))))

(fn write-byte (x o)
  (princ (code-char x) o))

(fn write-word (x o)
  (write-byte (bit-and x #xff) o)
  (write-byte (>> x 8) o))

(fn write-dword (x o)
  (write-word (bit-and x #xffff) o)
  (write-word (>> x 16) o))

(fn read-byte-string (i num &optional (eof nil))
  (list-string (@n [read-byte i eof] num)))

(fn gen-read-array (i reader num)
  (list-array (@n [~> reader i] num)))

(fn read-byte-array (i num &optional (eof nil))
  (gen-read-array i [read-byte _ eof] num))

(fn read-word-array (i num &optional (eof nil))
  (gen-read-array i [read-word _ eof] num))

(fn cr-or-lf? (x)
  (in? (char-code x) 10 13))

(fn read-line (&optional (str *standard-input*) (eof nil))
  (with-default-stream nstr str
    (with-queue q
      (while (!? (peek-char nstr eof)
                 (not (cr-or-lf? !)))
             (!? (peek-char nstr eof)
                 (when (cr-or-lf? !)
                   (enqueue q (read-char nstr eof))
                   (let-when c (peek-char nstr eof)
                     (& (cr-or-lf? c)
                        (not (character== c !))
                        (enqueue q (read-char nstr eof))))))
        (enqueue q (read-char nstr eof)))
      (!? (queue-list q)
          (list-string !)))))

(fn read-all-lines (&optional (str *standard-input*) (eof nil))
  (with-default-stream nstr str
    (with-queue q
      (awhile (read-line nstr eof)
              (queue-list q)
        (enqueue q !)))))

(fn ahead? (what str)
  (!= (peek-char str)
    (& (? (function? what)
          (~> what !)
          (eql what !))
       !)))

(fn read-decimal-places-0 (str v s eof)
  (? (ahead? #'digit? str)
     (read-decimal-places-0 str
                            (+ v (* s (digit-number (read-char str eof))))
                            (/ s 10)
                            eof)
     v))

(fn read-decimal-places (&optional (str *standard-input*) (eof nil))
  (& (ahead? #'digit? str)
     (read-decimal-places-0 str 0 0.1 eof)))

(fn read-integer-0 (str v eof)
  (? (ahead? #'digit? str)
     (read-integer-0 str (+ (* v 10) (digit-number (read-char str eof))) eof)
     v))

(fn read-integer (&optional (str *standard-input*) (eof nil))
  (& (ahead? #'digit? str)
     (integer (read-integer-0 str 0 eof))))

(fn read-number (&optional (str *standard-input*) (eof nil))
  (* (? (ahead? #\- str)
        (prog1 -1 (read-char str eof))
        1)
     (+ (read-integer str eof)
        (| (& (ahead? #\. str)
              (read-char str eof)
              (read-decimal-places str eof))
           0))))

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
  (when (ahead? #\; str)
    (skip-comment str))
  (when (ahead? #'whitespace? str)
    (read-char str)
    (skip-spaces str)))

(fn seek-char (str eof)
  (skip-spaces str)
  (peek-char str eof))

(fn read-symbol (str eof)
  (with (f [0 & (ahead? #'symbol-char? str)
                (. (read-char str eof) (f))]
         f2 [0 unless (| (not (peek-char str eof))
                         (ahead? #\| str))
                 (? (ahead? #\\ str)
                    (progn
                      (read-char str eof)
                      (. (read-char str eof) (f2)))
                    (. (read-char str eof) (f2)))])
    (? (ahead? #\| str)
       (progn
         (read-char str eof)
         (when (whitespace? (peek-char str eof))
           (return (… #\|)))
         (prog1 (f2)
           (? (ahead? #\| str)
              (read-char str eof)
              (error "Expected end of symbol name '|' instead of '~A'."
                     (peek-char str eof)))))
       (unless (special-char? (seek-char str eof))
         (filter #'char-upcase (f))))))

(fn read-symbol-and-package (str eof)
  (!= (read-symbol str eof)
    (? (ahead? #\: str)
       (progn
         (read-char str eof)
         (values (| (& ! (list-string !))
                    "KEYWORD")
                 (read-symbol str eof)))
       (values nil !))))

(fn read-string (str eof)
  (with (f [0 != (read-char str eof)
               (unless (eql ! #\")
                 (. (? (eql ! #\\)
                       (read-char str eof)
                       !)
                    (f)))})
    (list-string (f))))

(fn read-comment-block (str eof)
  (| (& (eql #\| (read-char str eof))
        (ahead? #\# str))
    (read-comment-block str eof)))

(fn list-number? (x)
  (& (| (& .x
           (| (eql #\- x.)
              (eql #\. x.)))
        (digit? x.))
     (? .x
        (every [| (digit? _)
                  (eql #\. _)]
               .x)
        t)))

(fn read-token (str eof)
  (awhen (read-symbol-and-package str eof)
    (with ((pkg sym) !)
      (values (? (& sym
                    (not .sym)
                    (eql #\. sym.))
                 :dot
                 (? sym
                    (? (list-number? sym)
                       :number
                       :symbol)
                    (case (read-char str eof)
                      #\(  :parenthesis-open
                      #\)  :parenthesis-close
                      #\[  :bracket-open
                      #\]  :bracket-close
                      #\{  :brace-open
                      #\}  :brace-close
                      #\'  :quote
                      #\`  :backquote
                      #\"  :dblquote
                      #\,  (? (ahead? #\@ str)
                              (progn
                                (read-char str eof)
                                :quasiquote-splice)
                              :quasiquote)
                      #\#  (case (read-char str eof)
                             #\\  :char
                             #\x  :hexnum
                             #\'  :function
                             #\(  :array
                             #\|  (read-comment-block str eof)
                             (error "Reader macro #~A unsupported." !))
                      -1   :eof)))
              (| pkg *package*)
              (list-string sym)))))

(fn read-make-symbol (sym &optional (pkg *package*))
  (| (find-symbol sym pkg)
     (make-symbol sym pkg)))

(fn read-slot-value (x)
  (?
    (not x)
      nil
    .x
      `(slot-value ,(read-slot-value (butlast x))
                   ',(read-make-symbol (car (last x))))
    (string? x.)
      (read-make-symbol x.)
    x.))

(fn read-symbol-or-slot-value (pkg sym)
  (!= (split #\. sym)
    (? (& .! !. (car (last !)))
       (read-slot-value !)
       (read-make-symbol sym pkg))))

(fn read-atom (str token pkg sym eof)
  (case token :test #'eq
    :dblquote   (read-string str eof)
    :char       (read-char str eof)
    :number     (with-stream-string s sym
                  (read-number s eof))
    :hexnum     (read-hex str eof)
    :array      (. 'array (read-cons-slot str eof))
    :function   `(function ,(read-expr str eof))
    :symbol     (read-symbol-or-slot-value pkg sym eof)
    (? (%read-closing-parens? token)
       (error "Unexpected closing ~A."
              (case token
                :parenthesis-close  "parenthesis"
                :brace-close        "brace"
                :bracket-close      "bracket"))
       (error "Closing bracket missing."))))

(fn read-quote (str token eof)
  (… (make-symbol (symbol-name token)) (read-expr str eof)))

(fn read-cons (str eof)
  (with (err
           [!= (stream-input-location str)
             (error "~A at line ~A, column ~A in file ~A."
                    _
                    (stream-location-line !)
                    (stream-location-column !)
                    (stream-location-id !))]
         f #'((token pkg sym)
               (unless (%read-closing-parens? token)
                 (. (case token
                      :parenthesis-open  (read-cons-slot str eof)
                      :bracket-open      (. 'brackets (read-cons-slot str eof))
                      :brace-open        (. 'braces   (read-cons-slot str eof))
                      (? (token-is-quote? token)
                         (read-quote str token eof)
                         (read-atom str token pkg sym eof)))
                    (!? (read-token str eof)
                        (with ((token pkg sym) !)
                          (? (eq :dot token)
                             (with (x                (read-expr str eof)
                                    (token pkg sym)  (read-token str eof))
                               (| (%read-closing-parens? token)
                                  (err "Only one value allowed after dotted cons"))
                               x)
                             (f token pkg sym)))
                        (err "Closing bracket missing")))))
         (token pkg sym)
           (read-token str eof))
    (? (eq token :dot)
       (. 'cons (read-cons str eof))
       (f token pkg sym))))

(fn read-cons-slot (str eof)
  (!= (read-cons str eof)
    (? (ahead? #\. str)
       (progn
         (read-char str eof)
         (with ((token pkg sym) (read-token str eof))
           (read-slot-value (… ! sym))))
       !)))

(fn read-expr (str eof)
  (with ((token pkg sym) (read-token str eof))
    (case token
      nil                nil
      :eof               nil
      :parenthesis-open  (read-cons-slot str eof)
      :bracket-open      (. 'brackets (read-cons-slot str eof))
      :brace-open        (. 'braces   (read-cons-slot str eof))
      (? (token-is-quote? token)
         (read-quote str token eof)
         (read-atom str token pkg sym eof)))))

(fn read (&optional (str *standard-input*) (eof nil))
  (& (seek-char str eof)
     (read-expr str eof)))

(fn read-all (str &optional (eof nil))
  (& (seek-char str eof)
     (. (read str eof)
        (read-all str eof))))

(fn read-from-string (x &optional (eof nil))
  (with-stream-string s x
    (read-all s eof)))
