; tré – Copyright (c) 2015 Sven Michael Klose <pixel@hugbox.org>

(def-pass-fun pass-dot-expand x
  (? (dot-expand?)                                                                                                                                          
     (dot-expand x)
     x))
