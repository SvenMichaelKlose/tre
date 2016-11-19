; tré – Copyright (c) 2006–2015 Sven Michael Klose <pixel@copei.de>

(mapcar-macro x
	'(quote %new
	  %%block %%go %%go-nil %%go-not-nil %%call-nil %%call-not-nil
	  %stack %stackarg %vec %set-vec %= %tag %%tag
	  %%native %%string
	  %closure %%closure
	  %set-local-fun
	  %function-prologue %function-return %function-epilogue
      %var %global
      %%comment)
  `(def-head-predicate ,x))

(defun atomic? (x)
  (| (atom x)
     (in? x. '%stack '%vec '%slot-value)))

(defun atomic-or-functional? (x)
  (| (atomic? x)
     (& (cons? x)
        (transpiler-functional? *transpiler* x.))))

(defun ~%ret? (x)
  (eq '~%ret x))

(defun vm-jump? (e)
  (& (cons? e)
     (in? e. '%%go '%%go-nil '%%go-not-nil)))

(defun %%go-cond? (x)
  (| (%%go-nil? x)
     (%%go-not-nil? x)))

(defun %%go-tag (x) .x.)
(defun %%go-value (x) ..x.)
(defun %=-place (x) .x.)
(defun %=-value (x) ..x.)

(defun %=-funcall? (x)
  (? (%=? x)
     (cons? (%=-value x))))

(defun %=-funcall-of? (x name)
  (& (%=-funcall? x)
     (eq name (car (%=-value x)))))

(defun has-return-value? (x)
  (not (| (vm-jump? x)
          (%var? x)
          (%%comment? x))))

(defun named-lambda? (x)
  (& (function-expr? x)
     ..x
     x))

(defun any-lambda? (x)
  (| (lambda? x)
     (named-lambda? x)))

(defun metacode-expression? (x)
  (& x
     (| (atom x)
        (%=? x)
        (vm-jump? x)
        (%var? x)
        (named-lambda? x))))
