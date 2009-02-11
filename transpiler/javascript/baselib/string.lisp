;;;;; Transpiler: TRE to JavaScript
;;;;; Copyright (c) 2008-2009 Sven Klose <pixel@copei.de>

(js-type-predicate stringp string)

(defun string-concat (&rest x)
  (apply #'+ x))

(defun %elt-string (seq idx)
  (code-char (seq.char-code-at idx)))

(defun %setf-elt-string (val seq idx)
  (assert (characterp val)
    (error "can only write CHARACTER to string"))
  (setf (aref seq idx) (*string.from-char-code (char-code val))))

(defun string (x)
  (if
	(stringp x)
	  x
	(characterp x)
      (char-string x)
    (symbolp x)
	  (symbol-name x)
   	(x.to-string)))

(defun list-string (lst)
  "Convert list of characters to string."
  (declare type cons lst)
  (when lst
    (let* ((n (length lst))
           (s (make-string 0)))
      (do ((i 0 (1+ i))
           (l lst (cdr l)))
          ((>= i n) s)
        (setf s (+ s (string (car l))))))))

(defun string= (x y)
  (%%%= x y))

(defun string-upcase (x)
  (x.to-upper-case))

(defun string-downcase (x)
  (x.to-lower-case))
