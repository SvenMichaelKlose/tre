; trè – Copyright (c) 2005–2016 Sven Michael Klose <pixel@copei.de>

(defconstant *printer-abbreviations* '((quote              "'")
                                       (backquote          "`")
                                       (quasiquote         ",")
                                       (quasiquote-splice  ",@")))

(defvar *print-automatic-newline?* t)
(defvar *always-print-package-names?* nil)
(defvar *printer-argument-definitions* (make-hash-table :test #'eq))
(defvar *invisible-package-names* '("TRE" "TRE-CORE"))

(defun add-printer-argument-definition (name x)
  (| (symbol? name)
     (%error "Function name symbol expected."))
  (| (list? x)
     (function? x)
     (%error "Argument definition list or printer function expected."))
  (= (href *printer-argument-definitions* name) x))

(add-printer-argument-definition '%%block '(&body body))
(add-printer-argument-definition 'progn   '(&body body))
(add-printer-argument-definition 'tagbody '(&body body))
(add-printer-argument-definition 'block   '(name &body body))
(add-printer-argument-definition 'cond    '(&body body))

(adolist *macros*
  (add-printer-argument-definition !. .!.))

(defun %get-printer-argument-definition (x)
  (href *printer-argument-definitions* x))

(defstruct print-info
  (pretty-print?  nil)
  (downcase?      nil)
  (indentation    0)
  (columns        nil))

(defun %print-gap (str)
  (| (fresh-line? str)
     (princ " " str)))

(defun %print-indentation (str info)
  (& (print-info-pretty-print? info)
     (fresh-line? str)
     (adotimes ((print-info-indentation info))
       (princ " " str))))

(defmacro %with-indentation (str info &body body)
  `{(%print-indentation ,str ,info)
    ,@body})

(defmacro %with-brackets (str info &body body)
  `(%with-indentation ,str ,info
     (push (stream-location-column (stream-output-location str))
           (print-info-columns ,info))
     (princ "(" ,str)
     ,@body
     (princ ")" ,str)
     (pop (print-info-columns ,info))))

(defun pretty-print-lambda (x str info)
  (%with-brackets str info
    (++! (car (print-info-columns info)))
    (%late-print (car .x.) str info)
    (& *print-automatic-newline?*
       (fresh-line str))
    (%print-body (cdr .x.) str info))
    (--! (car (print-info-columns info))))

(defun pretty-print-named-lambda (x str info)
  (%with-brackets str info
    (alet (++ (car (print-info-columns info)))
      (princ "FUNCTION " str)
      (%late-print .x. str info)
      (%print-gap str)
      (%late-print (car ..x.) str info)
      (& *print-automatic-newline?*
         (fresh-line str))
      (push ! (print-info-columns info))
      (%print-body (cdr ..x.) str info)
      (pop (print-info-columns info)))))

(defun pretty-print-lambdas (x str info)
  (?
    ..x          (pretty-print-named-lambda x str info)
    (cons? .x.)  {(princ "#'" str)
                  (pretty-print-lambda x str info)}
    {(princ "#'" str)
     (%print-symbol .x. str info)})
  t)

(add-printer-argument-definition 'function #'pretty-print-lambdas)

(defun %print-rest (x str info)
  (when x
    (? (cons? x)
       {(%print-gap str)
        (%late-print x. str info)
        (%print-rest .x str info)}
       {(princ " . " str)
        (%late-print x str info)})))

(defun %body-indentation (info)
  (| (car (print-info-columns info)) 1))

(defun %print-body (x str info)
  (with-temporary (print-info-indentation info) (%body-indentation info)
    (let first? t
      (adolist x
        (? first?
           (= first? nil)
           (& *print-automatic-newline?*
              (fresh-line str)))
        (%late-print ! str info)))))

(defun %print-call (x argdef str info)
  (debug-print x)
  (debug-print argdef)
  (%with-brackets str info
    (%late-print x. str info)
    (let expanded (%print-get-args .x argdef)
      (? (eq expanded 'error)
         (%print-rest .x str info)
         (adolist expanded
           (%print-gap str)
           (?
             (& (%body? .!) ..!)  {(& *print-automatic-newline?*
                                      (fresh-line str))
                                   (%print-body ..! str info)}
             (%rest? .!)          (%print-rest ..! str info)
             (%key? .!)           {(%print-symbol (make-keyword !.) str info)
                                   (princ " " str)
                                   (%late-print ..! str info)}
             (with-temporary *print-automatic-newline?* nil
               (%late-print .! str info))))))))

(defun %print-call? (x info)
  (& (print-info-pretty-print? info)
     (cons? x)
     x.
     (symbol? x.)
     (list? .x)
     (| (%get-printer-argument-definition x.)
        (unless (builtin? x.)
          (? (function? (symbol-function x.))
             (function-arguments x.))))))

(defun %print-list (x str info)
  (!? (%print-call? x info)
      (? (function? !)
         (funcall ! x str info)
         (%print-call x ! str info))
      (%with-brackets str info
        (%late-print x. str info)
        (%print-rest .x str info))))

(defun %print-abbreviation (abbreviation x str info)
  (%with-indentation str info
    (princ .abbreviation. str)
    (%late-print .x. str info)))

(defun %print-cons (x str info)
  (!? (& (cons? .x)
         (not ..x)
         (assoc x. *printer-abbreviations* :test #'eq))
      (%print-abbreviation ! x str info)
      (%print-list x str info)))

(defun %print-string (x str)
  (princ #\" str)
  (@ (i (string-list x))
    (?
      (eql i #\")  (princ "\\\"" str)
      (eql i #\\)  (princ "\\\\" str)
      (princ i str)))
  (princ #\" str))

(defun %print-escaped-symbol (x str)
  (princ #\| str)
  (@ (i (string-list x))
    (?
      (eql i #\|)  (princ "\\|" str)
      (princ i str)))
  (princ #\| str))

(defun symbol-char-needs-escaping? (x)
  (| (eql #\| x)
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

(defun invisible-package? (x)
  (alet (package-name x)
    (some [string== ! _] *invisible-package-names*)))

(defun invisible-package-name? (x)
  (unless (| (not x)
             (t? x)
             *always-print-package-names?*)
    (invisible-package? (symbol-package x))))

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
      (| (zero? i)
         (princ #\  str))
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
  (%with-indentation str info
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
    (? (& (cons? x)
          (cons? x.))
       (%with-brackets s print-info
         (%print-body x s print-info))
       (%late-print x s print-info))
    (& *print-automatic-newline?*
       (not (fresh-line? s))
	   (terpri s)))
  x)

(= *definition-printer* #'late-print)
