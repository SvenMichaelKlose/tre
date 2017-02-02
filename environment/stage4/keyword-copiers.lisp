(fn keyword-copiers (&rest x)
  (mapcan [list (make-keyword _) (make-symbol (symbol-name _))] x))

(fn keyword-argument-declarations (x)
  (& x `(&key ,@(@ [`(,_ nil)] x))))

(fn gen-vars-to-alist (x)
  (@ [`(. ,(make-keyword _), _)] x))
