;;;;; TRE environment
;;;;; Copyright (c) 2005-2011 Sven Klose <pixel@copei.de>

(defun %princ-character (c str)
  (setf (stream-last-char str) c)
  (funcall (stream-fun-out str) c str))

(defun %princ-number (c str)
  (with (recp #'((out n) ; XXX: REC will bug the expression-expander.
      			   (let m (mod n 10)
        			 (push m out)
        			 (? (> n 9)
          				(recp out (/ (- n m) 10))
          				out))))
    (dolist (i (recp nil c))
      (%princ-character (code-char (+ i #\0)) str))))

(defun %princ-string (obj str)
  (%princ-character obj str))
; Streams can handle characters and strings.
; XXX move to alternative section
;  (do ((i 0 (1+ i)))
;      ((>= i (length obj)))
;    (%princ-character (elt obj i) str)))

(defun princ (obj &optional (str *standard-output*))
  "Print object in human readable format."
  (with-default-stream s str
    (?
      (string? obj) (%princ-string obj s)
      (character? obj) (%princ-character obj s)
      (number? obj) (%princ-number obj s)
      (symbol? obj) (%princ-string (symbol-name obj) s))
	obj))

(defun terpri (&optional (str *standard-output*))
  "Open a new line."
  (with-default-stream s str
    (%princ-character (code-char 10) s)
    (force-output s)
    nil))

(defun fresh-line (&optional (str *standard-output*))
  "Open a new line if not already opened."
  (with-default-stream s str
    (unless (fresh-line? s)
      (terpri s)
      t)))

(defun %print-rest (c str visited)
  (? (href visited c)
     (princ "*circular*" str)
     (progn
       (setf (href visited c) t)
       (%late-print c. str visited)
       (let x .c
         (? x
            (? (cons? x)
               (progn
	             (princ #\  str)
                 (%print-rest x str visited))
	           (progn
			     (format str " . ")
                 (%print-atom x str visited)))
            (format str ")"))))))

(defun %print-cons (x str visited)
  (princ #\( str)
  (%print-rest x str visited))

(defun %print-string (x str)
  (princ #\" str)
  (dolist (c (string-list x))
	(? (= c #\")
	   (format str "\"")
	   (princ c str)))
  (princ #\" str))

(defun %print-symbol (x str)
  (when (keyword? x)
	(princ #\: str))
  (princ (symbol-name x) str))

(defun %print-array (x str visited)
  (? (href visited x)
     (princ "*circular*" str)
     (progn
       (setf (href visited x) t)
       (princ "#(" str)
       (dotimes (i (length x))
         (%late-print (aref x i) str visited)
         (princ " " str))
       (princ ")" str))))

(defun %print-atom (x str visited)
  (?
    (number? x) (princ x str)
    (string? x) (%print-string x str)
    (arrayp x) (%print-array x str visited)
    (%print-symbol x str)))

(defun %late-print (x str visited)
  (? (cons? x)
     (%print-cons x str visited)
     (%print-atom x str visited)))

(defun late-print (x &optional (str *standard-output*))
  (with-default-stream s str
    (%late-print x s (make-hash-table :test #'eq))
	(terpri s))
  x)
