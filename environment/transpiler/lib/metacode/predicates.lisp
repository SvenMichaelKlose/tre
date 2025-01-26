(progn
  ,@(@ [`(def-head-predicate ,_)]
       '(%= quote %new %closure
         %block %go %go-nil %go-not-nil %tag %tag
         %stack %stackarg %vec %set-vec %set-local-fun
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

(fn ~%ret? (x)
  (eq *return-id* x))

(fn some-%go? (e)
  (& (cons? e)
     (in? e. '%go '%go-nil '%go-not-nil)))

(fn conditional-%go? (x)
  (| (%go-nil? x)
     (%go-not-nil? x)))

(fn %go-tag (x)
  .x.)

(fn %go-value (x)
  ..x.)

(fn %=-funcall? (x)
  (? (%=? x)
     (cons? ..x.)))

(fn %=-funcall-of? (x name)
  (& (%=-funcall? x)
     (eq name ..x..)))

(fn has-return-value? (x)
  (not (| (some-%go? x)
          (%var? x)
          (%comment? x))))

(fn metacode-statement? (x)
  (| (number? x)
     (& (cons? x)
        (| (named-lambda? x)
           (in? x. '%= '%set-vec '%var '%function-prologue '%function-epilogue
                   '%function-return '%collection '%tag '%comment)
           (some-%go? x)))))

(fn modifies? (x place)
  (& (%=? x)
     (eq place (%=-place x))))

(fn uses? (x value)
  (tree-find value (%=-value x) :test #'equal))
