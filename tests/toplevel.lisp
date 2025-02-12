(fn compile-env-tests (tr)
  (!= (copy-transpiler tr)
    (= (transpiler-dump-passes? !) nil)
    (make-project
      :name
        (format nil "~A environment test" (transpiler-name !))
      :transpiler !
      :emitter
        [put-file (format nil "compiled/test.~A"
                          (transpiler-file-postfix !))
                  _]
      :sections
        (… (. 'tests     (make-environment-tests))
           (. 'toplevel  '((environment-tests)))))))

(fn compile-unit-tests (tr lst)
  (do ((n 1 (++ n))
       (i lst .i))
      ((not i))
    (!= i.
      (let tr (copy-transpiler tr)
        (= (transpiler-dump-passes? tr) nil)
        (make-project
            :transpiler tr
            :name       (format nil "Unit ~A: ~A" n .!.)
            :sections   (format nil "tests/unit-~A-~A.lisp" n !.)
            :emitter
              [put-file (format nil "compiled/unit-~A-~A.~A"
                                n !. (transpiler-file-postfix tr))
                        _])))))

(fn compile-tests (tr)
  (unix-sh-mkdir "compiled" :parents t)
  (compile-env-tests tr)
  (compile-unit-tests tr
    '(("class-basic"   "Simple class with public method")
      ("getter"        "Something with getters")
      ("base64"        "BASE64-ENCODE, BASE64-DECODE")
      ("slot-value"    "SLOT-VALUE as function")
      ("literal-json"  "Literal JSON object")
      ("nested-fn"     "Nested FN macros"))))
