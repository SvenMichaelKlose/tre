(fn %=-place (x)
 .x.)

(fn %=-value (x)
 ..x.)

(fn %=-atomic? (x)
  (& (%=? x)
     .x.
     (atom .x.)
     (atom ..x.)))
