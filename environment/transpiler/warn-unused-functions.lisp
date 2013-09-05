;;;;; tré – Copyright (c) 2013 Sven Michael Klose <pixel@copei.de>

(defun warn-unused-functions (tr)
  (alet (transpiler-defined-functions-hash tr)
    (dolist (i (+ (hashkeys (transpiler-used-functions tr))
                  (hashkeys (expander-macros (expander-get (transpiler-std-macro-expander tr))))
                  (hashkeys (expander-macros (expander-get (transpiler-codegen-expander tr))))
                  *macros*))
      (hremove ! i))
    (dolist (i (hashkeys !))
      (alet (symbol-name i)
        (unless (| (ends-with? ! "_TREEXP")
                   (starts-with? ! "~"))
          (warn "Unused function ~A." i))))))
