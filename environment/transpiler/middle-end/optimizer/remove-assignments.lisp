;;;;; tré - Copyright (c) 2008-2012 Sven Michael Klose <pixel@copei.de>

(def-opt-peephole-fun opt-peephole-remove-assignments
  (assignment-to-unneccessary-temoporary? a d)
	(let plc (%setq-place a)
	  (cons `(%setq ,(%setq-place d.) ,(%setq-value a))
	        (opt-peephole-remove-assignments .d))))
