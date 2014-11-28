;;;;; tré – Copyright (c) 2005–2006,2008-2009,2011–2013 Sven Michael Klose <pixel@hugbox.org>

(defmacro xchg (a b)
  (with-gensym g
    `(let ,g ,a
	   (= ,a ,b
	   	  ,b ,g))))
