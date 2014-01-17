;;;;; trè – Copyright (c) 2005–2014 Sven Michael Klose <pixel@copei.de>

(defstruct print-info
  (pretty-print?  nil)
  (indentation    0))

(defvar *print-automatic-newline?* t)

(defun %print-indentation (str info)
  (adotimes ((print-info-indentation info))
    (princ " " str)))

(defun %print-rest (x str info)
  (when x
    (? (cons? x)
       (progn
         (princ " " str)
         (%late-print x. str info)
         (%print-rest .x str info))
       (progn
         (princ " . " str)
         (%print-atom x str info)))))

(defun %print-body (x str info)
  (terpri str)
  (with-temporary (print-info-indentation info) (+ 2 (print-info-indentation info))
    (adolist x
      (%print-indentation str info)
      (%late-print ! str info)
      (unless (eq ! (car (last x)))
        (terpri str)))))

(defun %print-call (x argdef str info)
  (adolist ((%print-get-args x argdef))
    (? (cons? .!)
       (?
         (eq '&body .!.) (%print-body ..! str info)
         (eq '&rest .!.) (%print-rest ..! str info)
         (progn
           (princ " " str)
           (%print-cons .! str info)))
       (with-temporary *print-automatic-newline?* nil
         (princ " " str)
         (%late-print .! str info)))))

(defun %print-abbreviation (abbreviation x str info)
  (princ abbreviation)
  (%late-print .x. str info))

(defun %print-cons (x str info)
  (case x.
    'quote              (%print-abbreviation "'" x str info)
    'backquote          (%print-abbreviation "`" x str info)
    'quasiquote         (%print-abbreviation "," x str info)
    'quasiquote-splice  (%print-abbreviation ",@" x str info)
    'function           (%print-abbreviation "#'" x str info)
    (progn
      (princ "(" str)
      (%late-print x. str info)
      (!? (& (print-info-pretty-print? info)
             (symbol? x.)
             (!? (symbol-function x.)
                 (& (function? !)
                    (function-arguments !))))
          (%print-call .x ! str info)
          (%print-rest .x str info))
      (princ ")" str))))

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

(defun %print-array (x str info)
  (princ "#(" str)
  (dotimes (i (length x))
    (%late-print (aref x i) str info)
    (princ " " str))
  (princ ")" str))

(defun %print-function (x str info)
  (princ "#'" str)
  (%late-print (. (function-arguments x)
                  (function-body x))
               str info))

(defun %print-character (x str)
  (princ #\# str)
  (princ #\\ str)
  (princ x str))

(defun %print-atom (x str info)
  (?
    (character? x)  (%print-character x str)
    (number? x)     (princ x str)
    (string? x)     (%print-string x str)
    (array? x)      (%print-array x str info)
    (function? x)   (%print-function x str info)
    (symbol? x)     (%print-symbol x str)
    (object? x)     (%print-object x str info)
    "UNKNOWN OBJECT"))

(defun %late-print (x str info)
  (? (cons? x)
     (%print-cons x str info)
     (%print-atom x str info)))

(defun late-print (x &optional (str *standard-output*) (print-info nil))
  (with-default-stream s str
    (%late-print x s (| print-info (make-print-info)))
    (when *print-automatic-newline?*
	  (terpri s)))
  x)

(= *definition-printer* #'late-print)
