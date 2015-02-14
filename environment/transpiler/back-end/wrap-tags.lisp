; tré – Copyright (c) 2008–2010,2012–2013,2015 Sven Michael Klose <pixel@hugbox.org>

(metacode-walker wrap-tags-0 (x)
	:if-atom `((%%tag ,x.)))

(def-pass-fun wrap-tags x
  (wrap-tags-0 x))
