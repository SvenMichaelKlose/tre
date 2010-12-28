;;;;; Transpiler: TRE to PHP
;;;;; Copyright (c) 2008-2010 Sven Klose <pixel@copei.de>

(dont-obfuscate sizeof strlen)

(defun length (x)
  (when x
    (if
      (consp x)
	    (%list-length x)
      (stringp x)
	    (strlen x)
      (sizeof x))))

(dont-obfuscate fun hash)
(dont-inline map) ; XXX make it MAPHASH.

(defun map (fun hash)
  (%transpiler-native "$NULL;foreach ($hash as $i => $dummy) funcall ($i)"))
