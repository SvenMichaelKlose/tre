;;;;; tré – Copyright (c) 2008–2014 Sven Michael Klose <pixel@copei.de>

(dont-obfuscate is_string ord strlen substr strval strtoupper strtolower)

(defun string? (x)         (is_string x))
(defun string== (x y)      (%%%== x y))
(defun string-upcase (x)   (strtoupper x))
(defun string-downcase (x) (strtolower x))

(defun string-concat (&rest x)
  (!? (remove-if #'not x)
      (implode (list-phphash !))))

(defun %elt-string (seq idx)
  (when (%%%< idx (strlen seq))
    (code-char (ord (substr seq idx 1)))))

(defun string-subseq (seq start &optional (end 99999))
  (? (== start end)
	 ""
     (substr seq start (- end start))))

(defun number-string (x)
    (%%native "(string)$" x))
