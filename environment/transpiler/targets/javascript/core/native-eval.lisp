(var *native-eval-return-value* nil)

(fn native-eval (str)
  (unless (string? str)
    (late-print 'not-a-string)
    (late-print str))
  (%%%eval (late-print (+ (obfuscated-identifier '*native-eval-return-value*) "=" str ";")))
  *native-eval-return-value*)
