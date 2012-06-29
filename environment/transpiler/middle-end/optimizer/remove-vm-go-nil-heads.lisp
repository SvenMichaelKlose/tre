;;;;; tré – Copyright (c) 2008–2012 Sven Michael Klose <pixel@copei.de>

(defun vm-go-nil-head? (a d)
  (& d
     (%setq? a)
     (atom (%setq-value a))
     (%%vm-go-nil? d.)
     (let plc (%setq-place a)
       (& (eq plc (cadr d.))
          (removable-place? plc)
          (not (opt-peephole-will-be-used-again? (opt-peephole-tag-code (caddr d.)) plc))
          (not (opt-peephole-will-be-used-again? .d plc))))))

(def-opt-peephole-fun opt-peephole-remove-vm-go-nil-heads
  (vm-go-nil-head? a d)
    (cons `(%%vm-go-nil ,(%setq-value a) ,(caddr d.))
          (opt-peephole-remove-vm-go-nil-heads .d)))
