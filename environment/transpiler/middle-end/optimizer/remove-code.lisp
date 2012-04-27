;;;;; tré - Copyright (c) 2008-2012 Sven Michael Klose <pixel@copei.de>

(def-opt-peephole-fun opt-peephole-remove-code
  (assignment-to-unused-place? a d)
	(? (atomic-or-functional? (%setq-value a))
  	   (opt-peephole-remove-code d)
  	   (cons `(%setq nil ,(%setq-value a))
	         (opt-peephole-remove-code d))))
