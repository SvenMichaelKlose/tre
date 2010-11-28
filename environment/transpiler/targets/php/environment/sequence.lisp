;;;;; Transpiler: TRE to JavaScript
;;;;; Copyright (c) 2008-2009 Sven Klose <pixel@copei.de>

(dont-obfuscate length)

(defun length (x)
  (when x
    (if (consp x)
	    (%list-length x)
	    x.length)))

(dont-obfuscate fun hash)
(dont-inline map) ; XXX make it MAPHASH.

(defun map (fun hash)
  (%transpiler-native "$NULL;foreach ($hash as $i => $dummy) funcall ($i)"))
