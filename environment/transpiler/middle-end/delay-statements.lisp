(define-optimizer delay-statements
  ; Cannot delay past tags or jumps (yet).
  (| (some-%go? a)
     (atom a))
    x
  ; Delay (%= atom atom).
  (%=-atomic? a)
    (with (place  (%=-place a)
           value  (%=-value a)
           pos    (position-if [| (atom _)
                                  (some-%go? _)
                                  (modifies? _ value)
                                  (modifies? _ place)
                                  (uses? _ place)]
                               d))
      (? pos
         (!= `(,@(subseq d 0 pos)
               (%= ,place ,value)
               ,@(subseq d pos))
           (. !. (delay-statements .!)))
         (append d (… a)))))
