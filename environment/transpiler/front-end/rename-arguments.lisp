;;;;; tré – Copyright (c) 2005–2013 Sven Michael Klose <pixel@copei.de>

(defun rename-argument (replacements x)
  (| (assoc-value x replacements :test #'eq) x))

(defun rename-arguments-r (replacements x)
  (? (get-lambda-funinfo x)
     x
     (alet (+ (list-aliases (expanded-lambda-args x)) replacements)
	   (copy-lambda x :args (rename-arguments ! (lambda-args x))
                      :body (rename-arguments ! (lambda-body x))))))

(define-tree-filter rename-arguments (replacements x)
  (atom x)         (rename-argument replacements x)
  (%quote? x)      x
  (any-lambda? x)  (rename-arguments-r replacements x)
  (%slot-value? x) `(%slot-value ,(rename-arguments replacements .x.)
				                 ,..x.))
