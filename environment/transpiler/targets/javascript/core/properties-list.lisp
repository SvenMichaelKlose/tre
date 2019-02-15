(var *%properties-list-tmp* nil)

(defnative %properties-list-0 (key val)
  (acons! key val *%properties-list-tmp*))

(defnative %properties-list (hash)
  (= *%properties-list-tmp* nil)
  (%= nil (%%native
              "for (var k in " hash ") "
                  "if (k != \"" ,(obfuscated-identifier '__tre-object-id) "\""
                           " && k != \"" ,(obfuscated-identifier '__tre-test) "\""
                           " && k != \"" ,(obfuscated-identifier '__tre-keys) "\") "
                       ,(compiled-function-name-string '%properties-list-0) " (typeof k == \"string\" &&"
                                                                            " typeof " hash "." ,(obfuscated-identifier '__tre-keys) " != \"undefined\" ?"
                                                                                " (" hash "." ,(obfuscated-identifier '__tre-keys) "[k] || k) :"
                                                                                " k, " hash "[k])"))
  (reverse *%properties-list-tmp*))
