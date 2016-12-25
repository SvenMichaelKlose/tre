; tré – Copyright (c) 2008–2010,2012–2014 Sven Michael Klose <pixel@copei.de>

(defnative symbol (name pkg)
  (unless (%%%== "NIL" name)
    (| (%%%== "T" name)
       (new __symbol name pkg))))

(defnative =-symbol-function (v x)
  (x.sf v))
