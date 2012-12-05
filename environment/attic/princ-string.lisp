;;;;; tré – Copyright (c) 2005–2012 Sven Michael Klose <pixel@copei.de>

(defun %princ-character (c str)
  (unless (& (string? c) (zero? (length c)))
    (= (stream-last-char str) (? (string? c)
                                 (elt c (1- (length c)))
                                 c))
    (funcall (stream-fun-out str) c str)))

(defun integer-chars (x)
  (alet (mod x 10)
    (cons ! (& (<= 10 x)
               (integer-chars (/ (- x !) 10))))))

(defun fraction-chars (x)
  (alet (mod (* x 10) 10)
    (& (not (== 0 !))
       (cons (integer !) (fraction-chars !)))))

(defun %princ-number (c str)
  (when (< c 0)
    (princ #\- str))
  (dolist (i (reverse (integer-chars (abs c))))
    (%princ-character (code-char (+ i #\0)) str))
  (alet (mod c 1)
    (unless (zero? !)
      (princ #\. str)
      (dolist (i (fraction-chars !))
        (%princ-character (code-char (+ i #\0)) str)))))

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
