;;;;; Transpiler: TRE to PHP
;;;;; Copyright (c) 2008-2010 Sven Klose <pixel@copei.de>

(defvar *symbols* (make-hash-table))

(dont-obfuscate __symbol)

(define-native-php-fun symbol (name pkg)
  (unless (%%%= ,*nil-symbol-name* name)
	(let pkg-name (if pkg
					  pkg.n
					  ,*nil-symbol-name*)
      (let symbol-table (or (href *symbols* pkg-name)
	    				    (setf (href *symbols* pkg-name) (make-hash-table)))
        (or (href symbol-table name)
	        (setf (href symbol-table name) (new __symbol name pkg)))))))

(define-native-php-fun %%usetf-symbol-function (v x)
  (setf x.f v))
