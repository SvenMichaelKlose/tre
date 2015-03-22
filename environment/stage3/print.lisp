; trè – Copyright (c) 2005–2015 Sven Michael Klose <pixel@copei.de>

(defconstant *printer-abbreviations* '((quote              "'")
                                       (backquote          "`")
                                       (quasiquote         ",")
                                       (quasiquote-splice  ",@")
                                       (function           "#'")))

(defvar *print-automatic-newline?* t)
(defvar *always-print-package-names?* nil)

(defstruct print-info
  (pretty-print?  t)
  (downcase?      nil)
  (indentation    0))

(defun %print-gap (str)
  (| (fresh-line? str)
     (princ " " str)))

(defun %print-indentation (str info)
  (& (print-info-pretty-print? info)
     (fresh-line? str)
     (adotimes ((print-info-indentation info))
       (princ " " str))))

(defmacro %with-padding (str info &body body)
  `(progn
     (%print-indentation ,str ,info)
     ,@body))

(defmacro %with-brackets (str info &body body)
  `(%with-padding ,str, info
     (princ "(" ,str)
     ,@body
     (princ ")" ,str)))

(defun %print-rest (x str info)
  (when x
    (? (cons? x)
       (progn
         (%print-gap str)
         (%late-print x. str info)
         (%print-rest .x str info))
       (progn
         (princ " . " str)
         (%late-print x str info)))))

(defun %print-body (x str info)
  (with-temporary (print-info-indentation info) (++ (print-info-indentation info))
    (adolist x
      (fresh-line str)
      (%late-print ! str info))))

(defun %print-args (x str info)
  (? (eq x 'error)
     (%print-rest x str info)
     (adolist x
       (%print-gap str)
       (?
         (not !.)    (%with-brackets str info
                       (%print-args .! str info))
         (cons? .!)  (case .!. :test #'eq
                       '%body  (%print-body ..! str info)
                       '%rest  (%print-rest ..! str info)
                       (%print-cons .! str info))
         (with-temporary *print-automatic-newline?* nil
           (%late-print .! str info))))))

(defun %print-call (x argdef str info)
  (%print-args (%print-get-args x argdef) str info))

(defun %print-call? (x info)
  (& (print-info-pretty-print? info)
     (symbol? x.)
     (alet (symbol-function x.)
       (?
         (builtin? x.)   nil
         (function? !)  (function-arguments x.)))))

(defun %print-list (x str info)
  (%with-brackets str info
    (%late-print x. str info)
    (!? (%print-call? x info)
        (%print-call .x ! str info)
        (%print-rest .x str info))))

(defun %print-abbreviation (abbreviation x str info)
  (%with-padding str info
    (princ .abbreviation. str)
    (%late-print .x. str info)))

(defun %print-cons (x str info)
  (!? (& (not ..x)
         (assoc x. *printer-abbreviations* :test #'eq))
      (%print-abbreviation ! x str info)
      (%print-list x str info)))

(defun %print-string (x str)
  (princ #\" str)
  (@ (i (string-list x))
    (?
      (== i #\")  (princ "\\\"" str)
      (== i #\\)  (princ "\\\\" str)
      (princ i str)))
  (princ #\" str))

(defun %print-escaped-symbol (x str)
  (princ #\| str)
  (@ (i (string-list x))
    (?
      (== i #\|)  (princ "\\|" str)
      (princ i str)))
  (princ #\| str))

(defun symbol-char-needs-escaping? (x)
  (| (== #\| x)
     (lower-case? x)))

(defun %print-symbol-component (x str)
  (? (some #'symbol-char-needs-escaping? (string-list x))
     (%print-escaped-symbol x str)
     (princ x str)))

(defun abbreviated-package-name (x)
  (? (string== "COMMON-LISP" x)
     "CL"
     x))

(defun %print-symbol-package (name str)
  (%print-symbol-component (abbreviated-package-name name) str))

(defun invisible-package-name? (x)
  (unless (| (not x)
             (t? x)
             *always-print-package-names?*)
    (alet (package-name (symbol-package x))
      (| (string== ! "TRE")
         (string== ! "TRE-CORE")))))

(defun %print-symbol (x str info)
  (awhen (& x
            (not (t? x))
            (symbol-package x))
    (unless (invisible-package-name? x)
      (| (keyword? x)
         (%print-symbol-package (package-name !) str))
      (princ #\: str)))
  (%print-symbol-component (symbol-name x) str))

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

(defun %late-print (x str info)
  (%with-padding str info
    (pcase x
      cons?       (%print-cons x str info)
      symbol?     (%print-symbol x str info)
      character?  (%print-character x str)
      number?     (princ x str)
      string?     (%print-string x str)
      array?      (%print-array x str info)
      function?   (%print-function x str info)
      object?     (%print-object x str info)
      (%error "Don't know how to print object."))))

(defun late-print (x &optional (str *standard-output*)
                     &key (print-info (make-print-info)))
  (with-default-stream s str
    (funcall (? (& (cons? x) (cons? x.))
                #'%print-body
                #'%late-print)
             x s print-info)
    (& *print-automatic-newline?*
       (not (fresh-line? str))
	   (terpri s)))
  x)

(= *definition-printer* #'late-print)
