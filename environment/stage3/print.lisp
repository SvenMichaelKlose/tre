;;;; nix operating system project
;;;; list processor environment
;;;; Copyright (c) 2005-2008 Sven Klose <pixel@copei.de>
;;;;
;;;; Simple printing

(defun %princ-character (c str)
  (setf (stream-last-char str) c)
  (funcall (stream-fun-out str) c str))

(defun %princ-number (c str)
  (labels 
    ((rec (out n)
      (let m (mod n 10)
        (push m out)
        (if (> n 9)
          (rec out (/ (- n m) 10))
          out))))
    (dolist (i (rec nil c))
      (%princ-character (code-char (+ i #\0)) str))))

(defun %princ-string (obj str)
  (do ((i 0 (1+ i)))
      ((>= i (length obj)))
    (%princ-character (elt obj i) str)))

(defun princ (obj &optional (str *standard-output*))
  "Print object in human readable format."
  (cond
    ((stringp obj) (%princ-string obj str))
    ((characterp obj) (%princ-character obj str))
    ((numberp obj) (%princ-number obj str))
    ((symbolp obj) (%princ-string (symbol-name obj) str))))

(defun terpri (&optional (str *standard-output*))
  "Open a new line."
  (%princ-character (code-char 10) str)
  (force-output str)
  nil)

(defun fresh-line (&optional (str *standard-output*))
  "Open a new line if not already opened."
  (unless (fresh-line? str)
    (terpri str)
    t))

(defun %print-rest (c str)
  (newprint (car c) str)
  (with (x (cdr c))
    (if x
        (if (consp x)
            (progn
	          (princ #\  str)
              (%print-rest x str))
	        (progn
			  (format str " . ")
              (%print-atom x str)))
        (format str ")~%"))))

(defun %print-cons (x str)
  (princ #\( str)
  (%print-rest x str))

(defun %print-string (x str)
  (princ #\" str)
  (dolist (c (string-list x))
	(if (= c #\")
		(format str "\\\"")
		(princ c str)))
  (princ #\" str))

(defun %print-atom (x str)
  (cond
	((numberp x) (princ x str))
	((stringp x) (%print-string x str))
	(t			 (princ (symbol-name x) str))))

(defun print (x &optional (str *standard-output*))
  (if (consp x)
	  (%print-cons x str)
	  (%print-atom x str)))
