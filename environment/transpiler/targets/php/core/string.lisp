(defun string? (x)    (is_string x))
(defun string== (x y) (%%%== x y))
(defun upcase (x)     (strtoupper x))
(defun downcase (x)   (strtolower x))

(defmacro string== (x y)    ; TODO: &REST – share same code with JS core.
  `(%%%== ,x ,y))

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
