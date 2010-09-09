;;;; TRE compiler
;;;; Copyright (c) 2006-2010 Sven Klose <pixel@copei.de>
;;;;
;;;; Subatomic expression utilities.

(mapcar-macro x
	'(%quote %new
	  vm-scope vm-go vm-go-nil
	  %stack %vec %setq
	  %transpiler-native %transpiler-string
	  %inline
	  %function-prologue
	  %function-epilogue
	  %function-return)
  `(def-head-predicate ,x))

(defun atomic? (x)
  (or (atom x)
	  (in? x. '%stack '%vec '%slot-value)))

(defun atomic-or-without-side-effects? (x)
  (or (atomic? x)
	  (and (consp x)
	  	   (in? x. '%quote 'car '%car 'cdr '%cdr '%slot-value
				   '%vec '%stack
				   'cons 'list 'aref 'href 'car 'cdr 'list
				   'eq 'not '= '< '> '<= '>=
				   '%%%+ '%%%- '%%%= '%%%< '%%%> '%%%<= '%%%>= '%%%eq
				   '+ '-
				   'member 'append))))

(defun vm-jump? (e)
  (and (consp e)
	   (in? e. 'VM-GO 'VM-GO-NIL)))

(defun vm-jump-tag (x)
  (if
	(vm-go? x)
	  .x.
	(vm-go-nil? x)
	  ..x.))

(defun vm-scope-body (x)
  .x)

(defun %var? (x)
  (and (consp x)
	   (eq '%VAR x.)
	   (eq nil ..x)))

(defun %setqret? (x)
  (and (consp x)
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
    (if (consp v)
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

(defun %setq-named-function? (x)
  (and (%setq? x)
	   (named-function-expr? (%setq-value x))))

(defun %setq-funcall? (x)
  (and (%setq? x)
	   (consp (%setq-value x))))

(defun atom-or-quote? (x)
  (or (atom x)
	  (%quote? x)))
