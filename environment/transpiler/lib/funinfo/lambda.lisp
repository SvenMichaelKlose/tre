;;;;; tré – Copyright (c) 2008–2012 Sven Michael Klose <pixel@copei.de>

(defvar *funinfos* (make-hash-table :test #'eq))
(defvar *funinfos-reverse* (make-hash-table :test #'eq))

(defun make-lambda-funinfo (fi)
  (& (href *funinfos-reverse* fi)
	 (error "funinfo already memorized"))
  (= (href *funinfos-reverse* fi) t)
  (let g (funinfo-sym fi)
	(= (href *funinfos* g) fi)
	`(%funinfo ,g)))

(defun make-lambda-funinfo-if-missing (x fi)
  (| (lambda-funinfo-expr x)
     (make-lambda-funinfo fi)))

(defun make-missing-lambda-funinfo (x fi)
  (& (lambda-funinfo-expr x)
	 (error "already has funinfo expression"))
  (make-lambda-funinfo fi))

(defun lambda-head-w/-missing-funinfo (x fi)
  `(,@(make-lambda-funinfo-if-missing x fi)
	,(lambda-args x)))

(defun lambda-w/-missing-funinfo (x fi)
  `#'(,@(lambda-head-w/-missing-funinfo x fi)
		  ,@(lambda-body x)))

(defun get-funinfo-by-sym (x)
  (href *funinfos* x))

(defun get-lambda-funinfo (x)
  (get-funinfo-by-sym (lambda-funinfo x)))

(defun funinfo-expr-symbol (x)
  (& (eq '%funinfo x.) .x.))

(defun split-funinfo-and-args (x)
  (let fi-sym (funinfo-expr-symbol x)
    (values fi-sym (? fi-sym ..x x))))
