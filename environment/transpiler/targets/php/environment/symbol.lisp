;;;;; tré - Copyright (c) 2008-2010,2012 Sven Michael Klose <pixel@copei.de>

(defvar *symbols* (make-hash-table))

(dont-obfuscate __symbol)

(define-native-php-fun symbol (name pkg)
  (unless (%%%= ,*nil-symbol-name* name)
    (or (%%%= ,*t-symbol-name* name)
        (new __symbol name pkg))))
;	    (let pkg-name (? pkg pkg.n ,*nil-symbol-name*)
;          (let symbol-table (or (%%%href *symbols* pkg-name)
;	    				        (%%%href-set (make-hash-table) *symbols* pkg-name))
;            (or (%%%href symbol-table name)
;	            (%%%href-set (new __symbol name pkg) symbol-table name)))))))

(define-native-php-fun %%usetf-symbol-function (v x)
  (x.sf v))
