;;;;; tré - Copyright (c) 2008-2012 Sven Michael Klose <pixel@copei.de>

(def-opt-peephole-fun opt-peephole-remove-vm-go-nil-heads
  (vm-go-nil-head? a d)
    (cons `(%%vm-go-nil ,(%setq-value a) ,(caddr d.))
          (opt-peephole-remove-vm-go-nil-heads .d)))
