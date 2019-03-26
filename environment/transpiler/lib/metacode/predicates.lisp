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

(fn atomic? (x)
  (| (atom x)
     (in? x. '%stack '%vec '%slot-value)))

(fn atomic-or-functional? (x)
  (| (atomic? x)
     (& (cons? x)
        (transpiler-functional? *transpiler* x.))))

(fn ~%ret? (x)
  (eq '~%ret x))

(fn vm-jump? (e)
  (& (cons? e)
     (in? e. '%%go '%%go-nil '%%go-not-nil)))

(fn %%go-cond? (x)
  (| (%%go-nil? x)
     (%%go-not-nil? x)))

(fn %%go-tag (x) .x.)
(fn %%go-value (x) ..x.)

(fn %=-funcall? (x)
  (? (%=? x)
     (cons? ..x.)))

(fn %=-funcall-of? (x name)
  (& (%=-funcall? x)
     (eq name (car ..x.))))

(fn has-return-value? (x)
  (not (| (vm-jump? x)
          (%var? x)
          (%%comment? x))))

(fn named-lambda? (x)
  (& (function-expr? x)
     ..x
     x))

(fn any-lambda? (x)
  (| (lambda? x)
     (named-lambda? x)))

(fn metacode-expression? (x)
  (& x
     (| (atom x)
        (%=? x)
        (vm-jump? x)
        (%var? x)
        (named-lambda? x))))
