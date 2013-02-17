;;;; tré – Copyright (c) 2006–2013 Sven Michael Klose <pixel@copei.de>

(mapcar-macro x
	'(%quote %new
	  %%block %%go %%go-nil %%call-nil
	  %stack %stackarg %vec %set-vec %setq %tag %%tag
	  %transpiler-native %transpiler-string
	  %%closure %closure
	  %set-atom-fun
	  %setq-atom-value
	  %setq-atom-fun
	  %function-prologue
	  %function-epilogue
	  %function-return
      %var)
  `(def-head-predicate ,x))

(defun atomic? (x)
  (| (atom x)
     (in? x. '%stack '%vec '%slot-value)))

(defun atomic-or-functional? (x)
  (| (atomic? x)
     (& (cons? x) (functional? x.))))

(defun ~%ret? (x)
  (eq '~%ret x))

(defun atom-or-%quote? (x)
  (| (atom x)
     (%quote? x)))

(defun vm-jump? (e)
  (& (cons? e)
     (in? e. '%%go '%%go-nil)))

(defun %%go-tag (x)
  (?
	(%%go? x) .x.
	(%%go-nil? x) ..x.))

(defun %%block-body (x)
  .x)

(defun %setq-place (x)
  .x.)

(defun %setq-value (x)
  ..x.)

(defun %setq-value-atom? (x)
  (atom (%setq-value x)))

(defun %setq-args (x)
  (let v (%setq-value x)
    (? (cons? v)
	   .v
	   (list v))))

(defun %setq-lambda? (x)
  (& (%setq? x)
     (lambda? (%setq-value x))))

(defun %setq-funcall? (x)
  (? (%setq? x)
     (cons? (%setq-value x))))

(defun %setq-funcall-of? (x name)                                                                                                                                             
  (& (%setq-funcall? x)
     (eq name (car (%setq-value x)))))

(defun %slot-value-obj (x)
  .x.)

(defun %slot-value-slot (x)
  ..x.)

(defun has-return-value? (x)
  (not (| (vm-jump? x)
          (%var? x))))

(defun lambda-expression-needs-cps? (x)
  (& (lambda-expr? x)
     (funinfo-needs-cps? (get-lambda-funinfo x))))

(defun named-lambda? (x)
  (& (function-expr? x)
     ..x))

(defun vec-function-expr? (x)
  (& (cons? x)
     (eq x. 'function)
     (%vec? .x.)
     .x.))

(defun metacode-expression? (x)
  (| (atom x)
     (%setq? x)
     (vm-jump? x)
     (%var? x)
     (named-lambda? x)))

(defun metacode-expression-only (x)
  (& x (metacode-expression? x)))
