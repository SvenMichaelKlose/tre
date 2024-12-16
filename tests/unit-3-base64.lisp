(!= "This is a test of the base64 functions."
  (unless (equal ! (base64-decode (base64-encode !)))
    (error "BASE64-DECODE does not return a string equal to the input of BASE64-ENCODE. ~A instead of ~A."
           (base64-decode (base64-encode !)) !)))

(quit)
