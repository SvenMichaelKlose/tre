(progn
  ,@(@ [`(def-head-predicate ,_)]
       '(%string %global %stack %stackarg
         %vec %=-vec %set-local-fun %closure %native %new
         %block %go %go-nil %go-not-nil %tag
         %= %collection %var %comment
         %function-prologue %function-return %function-epilogue)))

(fn atomic? (x)
  (| (atom x)
     (in? x. 'quote '%stack '%vec '%slot-value '%global '%string)))

(fn atomic-or-functional? (x)
  (| (atomic? x)
     (& (cons? x)
        (transpiler-functional? *transpiler* x.))))

(fn some-%go? (e)
  (& (cons? e)
     (in? e. '%go '%go-nil '%go-not-nil)))

(fn conditional-%go? (x)
  (| (%go-nil? x)
     (%go-not-nil? x)))

(fn %go-tag (x)
  .x.)

(fn metacode-statement? (x)
  (| (number? x)
     (& (cons? x)
        (| (named-lambda? x)
           (in? x. '%= '%=-vec '%var '%function-prologue '%function-epilogue
                   '%function-return '%collection '%tag '%comment)
           (some-%go? x)))))
