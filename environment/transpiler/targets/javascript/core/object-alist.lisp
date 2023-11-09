(var *object-alist-tmp* nil)

(defnative object-alist-0 (key val)
  (acons! key val *object-alist-tmp*))

(defnative object-alist (hash)
  (= *object-alist-tmp* nil)
  (%= nil (%%native
              "for (var k in " hash ") "
                  "if (k != \"" ,(convert-identifier '__tre-object-id) "\""
                           " && k != \"" ,(convert-identifier '__tre-test) "\""
                           " && k != \"" ,(convert-identifier '__tre-keys) "\") "
                       ,(compiled-function-name-string 'object-alist-0) " (typeof k == \"string\" &&"
                                                                            " typeof " hash "." ,(convert-identifier '__tre-keys) " != \"undefined\" ?"
                                                                                " (" hash "." ,(convert-identifier '__tre-keys) "[k] || k) :"
                                                                                " k, " hash "[k])"))
  (reverse *object-alist-tmp*))
