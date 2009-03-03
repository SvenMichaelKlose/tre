;;;;; TRE environment
;;;;; Copyright (c) 2005-2009 Sven Klose <pixel@copei.de>
;;;;;
;;;;; Simple printing

(defun %princ-character (c str)
  (setf (stream-last-char str) c)
  (funcall (stream-fun-out str) c str))

(defun %princ-number (c str)
  (labels 
    ((recp (out n) ; XXX: REC will bug the expression-expander.
      (let m (mod n 10)
        (push m out)
        (if (> n 9)
          (recp out (/ (- n m) 10))
          out))))
    (dolist (i (recp nil c))
      (%princ-character (code-char (+ i #\0)) str))))

(defun %princ-string (obj str)
  (%princ-character obj str))
; XXX move to alternative section
;  (do ((i 0 (1+ i)))
;      ((>= i (length obj)))
;    (%princ-character (elt obj i) str)))

(defun princ (obj &optional (str *standard-output*))
  "Print object in human readable format."
  (if
    (stringp obj) (%princ-string obj str)
    (characterp obj) (%princ-character obj str)
    (numberp obj) (%princ-number obj str)
    (symbolp obj) (%princ-string (symbol-name obj) str)))

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
  (late-print (car c) str)
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

(defun %print-symbol (x str)
  (when (keywordp x)
	(princ #\: str))
  (princ (symbol-name x) str))

(defun %print-atom (x str)
  (if
	(numberp x) (princ x str)
	(stringp x) (%print-string x str)
	(%print-symbol x str)))

(defun late-print (x &optional (str *standard-output*))
  (with-default-stream s str
    (if (consp x)
	    (%print-cons x s)
	    (%print-atom x s))))
