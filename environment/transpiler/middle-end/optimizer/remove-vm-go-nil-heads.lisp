;;;;; tré – Copyright (c) 2008–2013 Sven Michael Klose <pixel@copei.de>

(defun vm-go-nil-head? (a d)
  (& d
     (%setq? a)
     (atom (%setq-value a))
     (with (plc (%setq-place a)
            n   d.)
       (& (%%vm-go-nil? n)
          (eq plc .n.)
          (removable-place? plc)
          (not (opt-peephole-will-be-used-again? (tag-code ..n.) plc))
          (not (opt-peephole-will-be-used-again? .d plc))))))

(def-opt-peephole-fun opt-peephole-remove-vm-go-nil-heads
  (vm-go-nil-head? a d)
    (cons `(%%vm-go-nil ,(%setq-value a) ,(caddr d.))
          .d))
