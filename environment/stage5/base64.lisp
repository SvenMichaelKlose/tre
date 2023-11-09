(defvar *base64-key*
        "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=")

(fn base64-encode (x)
  (apply #'string-concat
         (@ #'list-string
            (with (enc [elt *base64-key* _])
              (@ [list (enc
                         (>> _. 2))
                       (enc
                         (bit-or (<< (bit-and _. 3) 4)
                                 (>> (| ._. 0) 4)))
                       (enc
                         (? ._.
                            (bit-or (<< (bit-and ._. 15) 2)
                                    (>> (| .._. 0) 6))
                            64))
                       (enc
                         (? .._.
                            (bit-and .._. 63)
                            64))]
                 (group (@ #'char-code (array-list x)) 3))))))
 
(fn base64-compress (x)
  (when x
    (? (| (alphanumeric? x.)
          (in? x. #\+ #\/ #\=))
       (. x. (base64-compress .x))
       (base64-compress .x))))

(fn base64-decode (x)
  (with (dec [position _ *base64-key* :test #'character==])
    (apply #'string-concat
           (@ [list-string (@ [code-char _] _)]
              (@ [list (bit-or (<< (dec _.) 2)
                               (>> (dec ._.) 4))
                       (unless (== 64 (dec .._.))
                          (bit-or (<< (bit-and (dec ._.) 15) 4)
                                  (>> (dec .._.) 2)))
                       (unless (== 64 (dec ..._.))
                          (bit-or (<< (bit-and (dec .._.) 3) 6)
                                  (dec ..._.)))]
                 (group (base64-compress (string-list x)) 4))))))

(!= "This is a test of the base64 functions."
  (unless (equal ! (base64-decode (base64-encode !)))
    (error "BASE64-DECODE does not return a string equal to the input of BASE64-ENCODE. ~A instead of ~A."
           (base64-decode (base64-encode !)) !)))
