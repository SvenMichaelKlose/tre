(fn tre2cl (x)
  (make-lambdas (quote-expand (specialexpand (quote-expand x)))))

(var *eval* nil)

(defbuiltin eval (x)
  (cl:eval (= *eval* (tre2cl x))))
