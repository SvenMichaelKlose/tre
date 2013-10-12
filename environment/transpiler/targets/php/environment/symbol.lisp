;;;;; tré – Copyright (c) 2008–2010,2012–2013 Sven Michael Klose <pixel@copei.de>

(dont-obfuscate *symbol-values* *symbol-functions* __symbol n pn v f sv sf *keyword-package*)

(define-native-php-fun symbol (name pkg)
  (unless (%%%== ,*nil-symbol-name* name)
    (| (%%%== ,*t-symbol-name* name)
       (new __symbol name pkg))))

(define-native-php-fun =-symbol-function (v x)
  (x.sf v))
