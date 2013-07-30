;;;;; tré – Copyright (c) 2009,2013 Sven Michael Klose <pixel@copei.de>

(let x (block nil
			  1
			  (block some-block
			    (return 'fnord))
			  2)
  (unless (eq 'fnord x)
	(print x)
	(%error "BLOCK test failed.")))
