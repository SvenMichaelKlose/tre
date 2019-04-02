(var *%properties-list-tmp* nil)

(defnative %properties-list-0 (key val)
  (acons! key val *%properties-list-tmp*))

(defnative %properties-list (hash)
  (= *%properties-list-tmp* nil)
  (%= nil (%%native
              "for (var k in " hash ") "
                  "if (k != \"" ,(convert-identifier '__tre-object-id) "\""
                           " && k != \"" ,(convert-identifier '__tre-test) "\""
                           " && k != \"" ,(convert-identifier '__tre-keys) "\") "
                       ,(compiled-function-name-string '%properties-list-0) " (typeof k == \"string\" &&"
                                                                            " typeof " hash "." ,(convert-identifier '__tre-keys) " != \"undefined\" ?"
                                                                                " (" hash "." ,(convert-identifier '__tre-keys) "[k] || k) :"
                                                                                " k, " hash "[k])"))
  (reverse *%properties-list-tmp*))
