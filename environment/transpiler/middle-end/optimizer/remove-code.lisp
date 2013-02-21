;;;;; tré – Copyright (c) 2008–2013 Sven Michael Klose <pixel@copei.de>

(def-opt-peephole-fun opt-peephole-remove-code
  (& (%setq? a)
     (not (opt-peephole-will-be-used-again? d (%setq-place a))))
    (opt-peephole-remove-code (cons `(%setq nil ,(%setq-value a)) d))
  (& (%setq? a)
     (not (%setq-place a))
     (atomic-or-functional? (%setq-value a)))
    d)
