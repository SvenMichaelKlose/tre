;;;;; Transpiler: TRE to JavaScript
;;;;; Copyright (c) 2008-2010 Sven Klose <pixel@copei.de>

(dont-obfuscate length)

(defun length (x)
  (when x
    (if (consp x)
	    (%list-length x)
	    x.length)))

(dont-obfuscate fun hash)
(dont-inline map) ; XXX make it MAPHASH.

(defun maparray (fun hash)
  (%transpiler-native "null;for (i = 0; i < hash.length; i++) fun (hash[i])"))

(defun maphash (fun hash)
  (%transpiler-native "null;for (i in hash) fun (i, hash[i])"))

(defun elt (seq idx)
  (if
    (stringp seq)
	  (%elt-string seq idx)
    (consp seq)
	  (nth idx seq)
  	(aref seq idx)))

(defun (setf elt) (val seq idx)
  (if
	(stringp seq)
	  (error "strings cannot be modified")
	(arrayp seq)
  	  (setf (aref seq idx) val)
	(consp seq)
	  (rplaca (nthcdr idx seq) val)))
