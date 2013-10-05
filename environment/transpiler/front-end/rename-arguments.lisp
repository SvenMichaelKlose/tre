;;;;; tré – Copyright (c) 2005–2013 Sven Michael Klose <pixel@copei.de>

(define-gensym-generator argument-sym a)

(defun rename-argument (replacements x)
  (| (assoc-value x replacements :test #'eq) x))

(defun rename-arguments-lambda (replacements x)
  (? (get-lambda-funinfo x)
     x
     (alet (+ (list-aliases (expanded-lambda-args x) :gensym-generator #'argument-sym) replacements)
	   (copy-lambda x :args (rename-arguments-0 ! (lambda-args x))
                      :body (rename-arguments-0 ! (lambda-body x))))))

(define-tree-filter rename-arguments-0 (replacements x)
  (atom x)         (rename-argument replacements x)
  (%quote? x)      x
  (any-lambda? x)  (rename-arguments-lambda replacements x)
  (%slot-value? x) `(%slot-value ,(rename-arguments-0 replacements .x.)
				                 ,..x.))

(defun rename-arguments (x)
  (= *argument-sym-counter* 0)
  (rename-arguments-0 nil x))
