(fn compile-env-tests (tr)
  (make-project (format nil "~A environment test" (transpiler-name tr))
    (list "environment/stage3/type.lisp"
          (. 'tests (make-environment-tests))
          (. 'toplevel '((environment-tests))))
    :transpiler  (copy-transpiler tr)
    :emitter     [put-file (format nil "compiled/test.~A" (transpiler-file-postfix tr)) _]))

(fn compile-unit-tests (tr lst)
  (do ((n 1 (++ n))
       (i lst .i))
      ((not i))
    (!= i.
      (make-project (format nil "Unit ~A: ~A" n .!.)
        (format nil "tests/unit-~A-~A.lisp" n !.)
        :transpiler  (copy-transpiler tr)
        :emitter     [put-file (format nil "compiled/unit-~A-~A.~A" n !. (transpiler-file-postfix tr)) _]))))

(fn compile-tests (tr)
  (unix-sh-mkdir "compiled" :parents t)
  (compile-env-tests tr)
  (compile-unit-tests tr
    '(("smoke-test"  "Smoke test")
      ("getter"      "Something with getters")
      ("base64"      "BASE64-ENCODE, BASE64-DECODE")
      )))
;      ("slot-value"  "SLOT-VALUE as function"))))
