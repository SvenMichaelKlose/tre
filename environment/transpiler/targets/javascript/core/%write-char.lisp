; tré – Copyright (c) 2009–2015 Sven Michael Klose <pixel@copei.de>

(defnative %write-char (x)
  (? (defined? process)
     (%= nil (process.stdout.write (string x)))
     (%= nil (document.write (string x))))
  nil)
