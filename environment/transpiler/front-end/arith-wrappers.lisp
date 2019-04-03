; Catch codegen macros that made it into the host's EVAL.
; TODO: Not sure, if this is required anymore.  Must be some
; leftover from the compiler running in the brwowser.
{,@(@ [`(fn ,($ '%%% _) (&rest x)
          (apply (function ,_) x))]
      '(+ - == < > <= >=))}
