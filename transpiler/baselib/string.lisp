;;;;; Transpiler: TRE to JavaScript
;;;;; Copyright (c) 2008-2009 Sven Klose <pixel@copei.de>

(js-type-predicate stringp string)

;; XXX must be optional.
(defun string-concat (&rest x)
  (apply #'+ x))

;; XXX ECMAScript only.
(defun %elt-string (seq idx)
  (when (%%%< idx seq.length)
    (code-char (seq.char-code-at idx))))

;; XXX ECMAScript only.
(defun %setf-elt-string (val seq idx)
  (assert (characterp val)
    (error "can only write CHARACTER to string"))
  (setf (aref seq idx) (*string.from-char-code (char-code val))))

;; XXX ECMAScript only.
(defun string (x)
  (if
	(stringp x)
	  x
	(characterp x)
      (char-string x)
    (symbolp x)
	  (symbol-name x)
	(not x)
	  "NIL"
   	(x.to-string)))

(defun list-string (lst)
  "Convert list of characters to string."
  (declare type cons lst)
  (when lst
    (let* ((n (length lst))
           (s (make-string 0)))
      (do ((i 0 (1+ i))
           (l lst .l))
          ((>= i n) s)
        (setf s (+ s (string l.)))))))

;; XXX must be optional.
(defun string= (x y)
  (%%%= x y))

;; XXX ECMAScript only.
(defun string-upcase (x)
  (x.to-upper-case))

;; XXX ECMAScript only.
(defun string-downcase (x)
  (x.to-lower-case))

;; XXX ECMAScript only.
(defun %subseq-string (seq start end)
  (and seq
	   (%%%< start seq.length)
	   (seq.substr start end)))
