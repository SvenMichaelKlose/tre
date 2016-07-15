; tré – Copyright (c) 2013,2015–2016 Sven Michael Klose <pixel@copei.de>

(defun keyword-copiers (&rest x)
  (mapcan [list (make-keyword _) (make-symbol (symbol-name _))] x))

(defun keyword-argument-declarations (x)
  (& x `(&key ,@(@ [`(,_ nil)] x))))

(defun gen-vars-to-alist (x)
  (@ [`(. ,(make-keyword _), _)] x))
