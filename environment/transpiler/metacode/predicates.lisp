(progn
  ,@(@ [`(def-head-predicate ,_)]
       '(%= quote %new %closure
         %block %go %go-nil %go-not-nil %tag %tag
         %stack %stackarg %vec %=-vec %set-local-fun
         %string
         %function-prologue %function-return %function-epilogue %collection
         %native %var %global %comment)))

(fn atomic? (x)
  (| (atom x)
     (in? x. '%stack '%vec '%slot-value 'quote '%global '%string)))

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

(fn modifies? (x place)
  (& (%=? x)
     (eq place (%=-place x))))

(fn uses? (x value)
  (tree-find value (%=-value x) :test #'equal))
