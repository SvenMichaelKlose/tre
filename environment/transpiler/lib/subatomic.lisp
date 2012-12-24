;;;; tré – Copyright (c) 2006–2012 Sven Michael Klose <pixel@copei.de>

(mapcar-macro x
	'(%quote %new
	  %%vm-scope %%vm-go %%vm-go-nil %%vm-go-not-nil %%vm-call-nil
	  %stack %stackarg %vec %set-vec %setq %tag %%tag
	  %transpiler-native %transpiler-string
	  %%funref %funref
	  %set-atom-fun
	  %setq-atom-value
	  %setq-atom-fun
	  %function-prologue
	  %function-epilogue
	  %function-return)
  `(def-head-predicate ,x))

(defun atomic? (x)
  (| (atom x)
     (in? x. '%stack '%vec '%slot-value)))

(defun atomic-or-functional? (x)
  (| (atomic? x)
     (& (cons? x) (functional? x.))))

(defun vm-jump? (e)
  (& (cons? e)
     (in? e. '%%vm-go '%%vm-go-nil '%%vm-go-not-nil)))

(defun vm-conditional-jump? (x)
  (| (%%vm-go-nil? x)
     (%%vm-go-not-nil? x)))

(defun vm-jump-tag (x)
  (?
	(%%vm-go? x) .x.
	(vm-conditional-jump? x) ..x.))

(defun %%vm-scope-body (x)
  .x)

(defun %var? (x)
  (& (cons? x)
     (eq '%VAR x.)
     (eq nil ..x)))

(defun %setqret? (x)
  (& (cons? x)
     (eq '%SETQ x.)
     (eq '~%RET .x.)))

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

(defun %slot-value-obj (x)
  .x.)

(defun %slot-value-slot (x)
  ..x.)

(defun ~%ret? (x)
  (eq '~%ret x))

(defun %setq-lambda? (x)
  (& (%setq? x)
     (lambda? (%setq-value x))))

(defun %setq-named-lambda? (x)
  (& (%setq? x)
     (named-lambda? (%setq-value x))))

(defun %setq-named-function? (x)
  (& (%setq? x)
     (named-lambda? (%setq-value x))))

(defun %setq-funcall? (x)
  (? (%setq? x)
     (cons? (%setq-value x))))

(defun atom-or-%quote? (x)
  (| (atom x)
     (%quote? x)))

(defun has-return-value? (x)
  (not (| (vm-jump? x)
          (%var? x))))

(defun lambda-expression-needs-cps? (x)
  (& (lambda-expr? x)
     (funinfo-needs-cps? (get-lambda-funinfo x))))
