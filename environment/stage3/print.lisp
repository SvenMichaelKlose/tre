;;;;; trè – Copyright (c) 2005–2014 Sven Michael Klose <pixel@copei.de>

(defstruct print-info
  (pretty-print?  nil)
  (downcase?      nil)
  (indentation    0)
  (no-padding?    t))

(defvar *print-automatic-newline?* t)

(defun %print-indentation (str info)
  (adotimes ((print-info-indentation info))
    (princ " " str))
  (= (print-info-no-padding? info) t))

(defmacro %with-padding (str info &body body)
  `(progn
     (? (print-info-no-padding? ,info)
        (= (print-info-no-padding? ,info) nil)
        (princ " " ,str))
     ,@body))

(defmacro %with-brackets (str info &body body)
  `(%with-padding ,str, info
     (princ "(" ,str)
     (= (print-info-no-padding? ,info) t)
     ,@body
     (princ ")" ,str)))

(defun %print-rest (x str info)
  (when x
    (? (cons? x)
       (progn
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

(defun %print-args (x str info)
  (adolist x
    (?
      (not !.)    (%with-brackets str info
                    (%print-args .! str info))
      (cons? .!)  (case .!. :test #'eq
                    '&body  (%print-body ..! str info)
                    '&rest  (%print-rest ..! str info)
                    (%print-cons .! str info))
      (with-temporary *print-automatic-newline?* nil
        (%late-print .! str info)))))

(defun %print-call (x argdef str info)
  (%print-args (%print-get-args x argdef) str info))

(defun %print-abbreviation (abbreviation x str info)
  (princ abbreviation str)
  (%with-brackets str info
    (%late-print .x. str info)))

(defconstant *printer-abbreviations* '((quote              "'")
                                       (backquote          "`")
                                       (quasiquote         ",")
                                       (quasiquote-splice  ",@")
                                       (function           "#'")))

(defun %print-call? (x info)
  (& (print-info-pretty-print? info)
     (symbol? x.)
     (!? (symbol-function x.)
         (& (function? !)
            (function-arguments !)))))

(defun %print-list (x str info)
  (%with-brackets str info
    (%late-print x. str info)
    (!? (%print-call? x info)
        (%print-call .x ! str info)
        (%print-rest .x str info))))

(defun %print-cons (x str info)
  (!? (assoc x. *printer-abbreviations* :test #'eq)
      (%print-abbreviation .!. x str info)
      (%print-list x str info)))

(defun %print-string (x str)
  (princ #\" str)
  (dolist (i (string-list x))
    (?
      (== i #\")  (princ "\\\"" str)
      (== i #\\)  (princ "\\\\" str)
      (princ i str)))
  (princ #\" str))

(defun %print-symbol (x str info)
  (with (conv [? (print-info-downcase? info)
                 (downcase _)
                 _])
    (princ (conv (symbol-name x)) str)
    (awhen (symbol-package x)
      (princ #\: str)
      (princ (conv (package-name !)) str))))

(defun %print-array (x str info)
  (princ "#" str)
  (%with-brackets str info
    (doarray (i x)
      (%late-print i str info))))

(defun %print-function (x str info)
  (princ "#'" str)
  (%late-print (. (function-arguments x)
                  (function-body x))
               str info))

(defun %print-character (x str)
  (princ "#\\" str)
  (princ x str))

(defun %print-atom (x str info)
  (%with-padding str info
    (?
      (symbol? x)     (%print-symbol x str info)
      (character? x)  (%print-character x str)
      (number? x)     (princ x str)
      (string? x)     (%print-string x str)
      (array? x)      (%print-array x str info)
      (function? x)   (%print-function x str info)
      (object? x)     (%print-object x str info)
      "UNKNOWN OBJECT")))

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
