;;;;; trè – Copyright (c) 2005–2012 Sven Michael Klose <pixel@copei.de>

(defun %print-first-occurence (x str info)
  (hremove (print-info-first-occurences info) x)
  (princ "(%%reference " str)
  (princ (%%id x) str)
  (princ " " str)
  (%late-print x str info)
  (princ ")" str))

(defun %print-circularity (x str)
  (princ "(%%circular " str)
  (princ (%%id x) str)
  (princ ")" str))

(defun %print-check-circularity (x str info)
  (? *print-circularities?*
     (?
       (href (print-info-first-occurences info) x) (%print-first-occurence x str info)
       (href (print-info-visited info) x) (%print-circularity x str))))

(defun %print-rest-0 (c str info)
;  (= (href (print-info-visited info) c) t)
  (awhen (cpr c)
    (princ #\[ str)
    (princ !. str)
    (princ #\, str)
    (princ (car .!) str)
    (princ #\, str)
    (princ (cdr .!) str)
    (princ #\] str))
  (%late-print c. str info)
  (let x .c
    (? x
       (? (cons? x)
          (progn
            (princ #\  str)
            (%print-rest x str info))
          (progn
		    (princ " . " str)
            (%print-atom x str info)
            (princ ")" str)))
       (princ ")" str))))

(defun %print-rest (x str info)
;  (| (%print-check-circularity x str info)
     (%print-rest-0 x str info));)

(defun %print-cons (x str info)
  (princ #\( str)
  (%print-rest x str info))

(defun %print-string (x str)
  (princ #\" str)
  (dolist (i (string-list x))
	(?
      (== i #\") (princ "\\\"" str)
      (== i #\\) (princ "\\\\" str)
	  (princ i str)))
  (princ #\" str))

(defun %print-symbol (x str)
  (awhen (symbol-package x)
	(princ (symbol-name !) str)
	(princ #\: str))
  (princ (symbol-name x) str))

(defun %print-array-0 (x str info)
;  (& *print-circularities?*
;     (= (href (print-info-visited info) x) t))
  (princ "#(" str)
  (dotimes (i (length x))
    (%late-print (aref x i) str info)
    (princ " " str))
  (princ ")" str))

(defun %print-array (x str info)
;  (| (%print-check-circularity x str info)
     (%print-array-0 x str info));)

(defun %print-function-0 (x str info)
  (princ "#'" str)
  (%late-print (cons (function-arguments x)
                     (function-body x))
               str info))

(defun %print-function (x str info)
;  (| (%print-check-circularity x str info)
     (%print-function-0 x str info));)

(defun %print-character (x str)
  (princ #\# str)
  (princ #\\ str)
  (princ x str))

(defun %print-atom (x str info)
  (?
    (character? x) (%print-character x str)
    (number? x)    (princ x str)
    (string? x)    (%print-string x str)
    (array? x)     (%print-array x str info)
    (function? x)  (%print-function x str info)
    (symbol? x)    (%print-symbol x str)
    (object? x)    (%print-object x str info)
    "UNKNOWN OBJECT"))

(defun %late-print (x str info)
  (? (cons? x)
     (%print-cons x str info)
     (%print-atom x str info)))

(defun late-print (x &optional (str *standard-output*))
  (with-default-stream s str
    (%late-print x s (print-trace x))
	(terpri s))
  x)

(= *definition-printer* #'late-print)
