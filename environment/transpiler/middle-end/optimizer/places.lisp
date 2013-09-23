;;;;; tré – Copyright (c) 2008–2013 Sven Michael Klose <pixel@copei.de>

(define-optimizer optimize-places
  (& (%setq? a)
     (%setq? d.)
     (eq (%setq-place a) (%setq-value d.))
     (not (opt-peephole-will-be-used-again? .d (%setq-place a))))
    (cons `(%setq ,(%setq-place d.) ,(%setq-value a))
          (optimize-places .d))
  (& (%setq? a)
     (not (opt-peephole-will-be-used-again? d (%setq-place a))))
    (cons `(%setq nil ,(%setq-value a))
          (optimize-places d)))
