;;;;; tré – Copyright (c) 2008–2010,2012 Sven Michael Klose <pixel@copei.de>

(metacode-walker transpiler-finalize-sexprs (x)
	:if-atom `((%%tag ,x.)))
