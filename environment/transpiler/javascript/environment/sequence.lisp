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
  (%transpiler-native "null;for (i in hash) fun (i)"))

(defun elt (seq idx)
  (if
    (stringp seq)
	  (%elt-string seq idx)
    (consp seq)
	  (nth idx seq)
  	(aref seq idx)))

(defun (setf elt) (val seq idx)
  (if (stringp seq)
	  (error "strings cannot be modified")
  	  (setf (aref seq idx) val)))
