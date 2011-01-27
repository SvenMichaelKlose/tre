;;;;; Transpiler: TRE to PHP
;;;;; Copyright (c) 2008-2011 Sven Klose <pixel@copei.de>

(dont-obfuscate sizeof strlen)

(defun length (x)
  (when x
    (?
      (cons? x)
	    (%list-length x)
      (string? x)
	    (strlen x)
      (sizeof x))))

(dont-obfuscate fun hash)
(dont-inline map) ; XXX make it MAPHASH.

(defun map (fun hash)
  (%transpiler-native "$null;foreach ($hash as $i => $dummy) funcall ($i);"))
