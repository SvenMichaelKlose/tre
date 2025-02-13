(fn tre2cl (x)
  (make-lambdas (convert-toplevel-lambdas (quote-expand (specialexpand (quote-expand x))))))

(var *eval* nil)

(defbuiltin eval (x)
  (CL:EVAL (= *eval* (tre2cl x))))
