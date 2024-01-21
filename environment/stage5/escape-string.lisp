(fn escape-string (x &optional (quote-char #\") (chars-to-escape #\"))
  (ensure-list! chars-to-escape)
  (with (f [when _
             (?
               (eql #\\ _.)
                 (. #\\ (? (& ._ (digit? ._.))
                           (f ._)
                           (. #\\ (f ._))))
               (eql quote-char _.)
                 (. #\\ (. _. (f ._)))
               (member _. chars-to-escape :test #'character==)
                 (. #\\ (. _. (f ._)))
               (. _. (f ._)))])
    (list-string (f (string-list x)))))
