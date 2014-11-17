;;;;; tré – Copyright (c) 2014 Sven Michael Klose <pixel@copei.de>

(defpackage :tre-init (:use :common-lisp))
(in-package :tre-init)

(defconstant +direct-imports+
    '(nil t not eq eql atom setq
      cons car cdr rplaca rplacd
      apply eval
      progn block
      + - * / < >
      mod sqrt sin cos atan exp round floor
      last copy-list nthcdr nth mapcar elt length make-string string
      make-array aref code-char char-code integer
      make-symbol make-package
      symbol-name symbol-value symbol-function symbol-package
      logxor bit-and
      defvar
      defun
      identity list copy-list))

(defconstant +renamed-imports+
    '((cons? consp)
      (symbol? symbolp)
      (function? functionp)
      (string? stringp)
      (array? arrayp)
      (number? numberp)
      (character? characterp)
      (%+ +)
      (%- -)
      (number+ +)
      (integer+ +)
      (character+ +)
      (number- -)
      (integer- -)
      (character- -)
      (== =)
      (number== =)
      (integer== =)
      (character== =)
      (number< <)
      (integer< <)
      (character< <)
      (number> >)
      (integer> >)
      (character> >)
;      (debug invoke-debugger)
      (%error error)
      (%nconc nconc)))

(defconstant +core-variables+
    '(*universe* *variables*
      *environment-path* *environment-filenames*
      *macroexpand-hook* *quasiquoteexpand-hook*
      *default-listprop*))

(defconstant +implementations+
    '(cpr rplacp
      %load atan2 pow quit
      %set-atom-fun string-concat env-load
      %defvar %defun))

(defun make-keyword (x)
  (values (intern (symbol-name x) "KEYWORD")))

(defun make-keywords (x)
  (mapcar #'make-keyword x))

(defun unique (x)
  (when x
    (if (member (car x) (cdr x) :test #'eq)
        (cdr x)
        (cons (car x) (unique (cdr x))))))

(defun all-builtins ()
  (make-keywords (append +direct-imports+ (mapcar #'car +renamed-imports+))))

(defmacro define-core-package ()
  `(progn
     (defpackage :tre-core
       (:use :common-lisp :tre-init)
       (:shadow :*macroexpand-hook*)
       (:export ,@(all-builtins)))
     ,@(mapcar #'(lambda (x)
                   `(defun ,(car x) (&rest x)
                      (apply (function ,(cadr x)) x)))
               +renamed-imports+)))

(define-core-package)
(in-package :tre-core)

(defvar *universe* nil)
(defvar *variables* nil)
(defvar *environment-path* ".")
(defvar *environment-filenames* nil)
(defvar *macroexpand-hook* nil)
(defvar *quasiquoteexpand-hook* nil)
(defvar *default-listprop* nil)

(defvar *macros* (make-hash-table :test #'eq))
(defvar *builtins* (make-hash-table :test #'eq))
(defvar *function-sources* (make-hash-table :test #'eq))

(defun cpr (x))
(defun rplacp (v x))

(defun builtin? (x) (gethash x *builtins*))
(defun macro? (x) (gethash x *macros*))

(defun =-aref (v x &rest indexes) (apply #'aref x indexes))

(defun file-exists? (pathname) (error "Not implemented."))
(defun %fopen (pathname access-mode) (error "Not implemented."))

(defun quit (x) (error "Not implemented."))
(defun %load (x) (error "Not implemented."))

(defun %malloc (num-bytes) (error "Not implemented."))
(defun %malloc-exec (num-bytes) (error "Not implemented."))
(defun %free (address) (error "Not implemented."))
(defun %free-exec (address) (error "Not implemented."))
(defun %%set (address byte) (error "Not implemented."))
(defun %%get (address) (error "Not implemented."))

(defun function-native (x) x)
(defun function-bytecode (x) (error "Not implemented."))
(defun =-function-bytecode (v x) (error "Not implemented."))
(defun function-source (x) (href *function-sources* x))
(defun =-function-source (v x) (setf (href *function-sources* x) v))

(defun bit-or (a b) (bit-or a b) (error "Not implemented."))
(defun << (x num-bits-to-left) (error "Not implemented."))
(defun >> (x num-bits-to-right) (error "Not implemented."))

(defun =-symbol-value (x) (error "Not implemented."))
(defun %setq-atom-value (value symbol) (error "Not implemented."))
(defun =-symbol-function (x) (error "Not implemented."))

(defun filter (fun x) (mapcar fun x) (error "Not implemented."))
(defun %set-elt (object sequence index) (error "Not implemented."))

(defun %fclose (stream-handle) (error "Not implemented."))
(defun %directory (pathname) (error "Not implemented."))
(defun %stat (pathname) (error "Not implemented."))
(defun readlink (pathname) (error "Not implemented."))

(defun %terminal-raw () (error "Not implemented."))
(defun %terminal-normal () (error "Not implemented."))
(defun end-debug () (error "Not implemented."))

(defun alien-dlopen (path-to-shared-library) (error "Not implemented."))
(defun alien-dlsym (handle) (error "Not implemented."))
(defun alien-call (address) (error "Not implemented."))

(defun open-socket (port-number) (error "Not implemented."))
(defun accept () (error "Not implemented."))
(defun recv () (error "Not implemented."))
(defun send (string) (error "Not implemented."))
(defun close-connection () (error "Not implemented."))
(defun close-socket () (error "Not implemented."))

(defun %type-id (x) (error "Not implemented."))
(defun %%id (x) (error "Not implemented."))
(defun %strerror (x) (error "Not implemented."))
(defun atan2 (x) (error "Not implemented."))
(defun pow (x) (error "Not implemented."))
(defun quit (x) (error "Not implemented."))

(defun %set-atom-fun (x v) (setf (symbol-function x) v))

(defun string-concat (&rest x)
  (apply #'concatenate 'string x))

(defmacro %defvar (&rest x) `(defvar ,@x))
(defmacro %defun (&rest x) `(defun ,@x))
(defmacro %defmacro (&rest x) `(defmacro ,@x))

(defun read-file (pathname)
  (with-open-file (s pathname)
    (do ((result nil (cons next result))
         (next (read s nil 'eof) (read s nil 'eof)))
        ((equal next 'eof) (reverse result)))))

(defun %load (pathname)
  (dolist (i (read-file pathname))
    (eval (print (macroexpand `(progn (in-package :tre) ,i))))))

(defun env-load (pathname &optional (target nil))
  (push (cons pathname target) *environment-filenames*)
  (%load (string-concat *environment-path* "/environment/" pathname)))


(in-package :tre-init)

(defmacro define-user-package ()
  `(defpackage :tre 
     ,@(mapcar #'(lambda (x)
                   `(:import-from :tre-core ,(make-keyword x)))
               (append +direct-imports+
                       (unique (mapcar #'cadr +renamed-imports+))
                       +core-variables+
                       +implementations+))))

(define-user-package)


(in-package :tre-core)

(env-load "env-load-cl.lisp")
