; tré – Copyright (c) 2008–2010,2012–2014 Sven Michael Klose <pixel@copei.de>

(dont-obfuscate *symbol-values* *symbol-functions* *keyword-package*
                __symbol n pn v f sv sf)

(define-native-php-fun symbol (name pkg)
  (unless (%%%== "NIL" name)
    (| (%%%== "T" name)
       (new __symbol name pkg))))

(define-native-php-fun =-symbol-function (v x)
  (x.sf v))
