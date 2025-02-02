(fn make-c-newlines (x)
  (list-string (+@ [? (== 10 (char-code _))
                      `(#\\ #\n)
                      `(,_)]
                   (string-list x))))

(fn literal-string (x &key (quote-char #\")
                           (chars-to-escape #\"))
  (string-concat (string quote-char)
                 (make-c-newlines (escape-string x quote-char chars-to-escape))
                 (string quote-char)))
