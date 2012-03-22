;;;; tré compiler -- Copyright (c) 2006-2011 Sven Klose <pixel@copei.de>

(mapcar-macro x
	'(%quote %new
	  %%vm-scope %%vm-go %%vm-go-nil %%vm-go-not-nil %%vm-call-nil
	  %stack %vec %set-vec %setq %tag
	  %transpiler-native %transpiler-string
	  %%funref
	  %set-atom-fun
	  %setq-atom-value
	  %setq-atom-fun
	  %function-prologue
	  %function-epilogue
	  %function-return)
  `(def-head-predicate ,x))

(defun atomic? (x)
  (or (atom x)
	  (in? x. '%stack '%vec '%slot-value)))

(defun atomic-or-functional? (x)
  (or (atomic? x)
	  (and (cons? x)
           (functional? x.))))

(defun vm-jump? (e)
  (and (cons? e)
	   (in? e. '%%vm-go '%%vm-go-nil '%%vm-go-not-nil)))

(defun vm-jump-tag (x)
  (?
	(%%vm-go? x)
      .x.
	(or (%%vm-go-nil? x)
        (%%vm-go-not-nil? x))
      ..x.))

(defun %%vm-scope-body (x)
  .x)

(defun %var? (x)
  (and (cons? x)
	   (eq '%VAR x.)
	   (eq nil ..x)))

(defun %setqret? (x)
  (and (cons? x)
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
  (and (%setq? x)
	   (lambda? (%setq-value x))))

(defun %setq-named-lambda? (x)
  (and (%setq? x)
	   (named-lambda? (%setq-value x))))

(defun %setq-named-function? (x)
  (and (%setq? x)
	   (named-lambda? (%setq-value x))))

(defun %setq-funcall? (x)
  (and (%setq? x)
	   (cons? (%setq-value x))))

(defun atom-or-%quote? (x)
  (or (atom x)
	  (%quote? x)))
