;;;;; tré – Copyright (c) 2014 Sven Michael Klose <pixel@copei.de>
;;;;;
;;;;; Common Lisp replacement for the C core.
;;;;;
;;;;; *** UNDER CONTRUCTION!!! ***
;;;;;
;;;;; The interpreter is spoiling everthing. Don't try to use
;;;;; tré before this thing here is working.


;;;; Initialization package

(defpackage :tre-init
  (:use :common-lisp)
  (:export :+renamed-imports+
           :make-keyword
           :cl-peek-char :cl-read-char))

(in-package :tre-init)

;;; Symbols directly imported from package CL-USER.
(defconstant +direct-imports+
    '(nil t not eq eql atom setq
      cons car cdr rplaca rplacd
      apply eval
      progn block
      * / < >
      mod sqrt sin cos atan exp round floor
      last copy-list nthcdr nth member mapcar elt length make-string string
      make-array aref code-char char-code integer
      make-symbol make-package
      symbol-name symbol-value symbol-function symbol-package
      logxor bit-and
      print
      defvar
      defun
      identity list copy-list))

;;; Functions we import from CL-USER, wrap and export to package TRE.
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
      (%error error)
      (%nconc nconc)))

;;; Global variables provided by all tré cores.
(defconstant +core-variables+
    '(*universe* *variables* *defined-functions*
      *environment-path* *environment-filenames*
      *macroexpand-hook* *quasiquoteexpand-hook*
      *default-listprop*))

;;; Things we have to implement ourselves.
(defconstant +implementations+
    '(%set-atom-fun cpr rplacp %load atan2 pow quit string-concat %load
      %defun early-defun %defvar %defmacro
      ? functional
      builtin? macro?
      %%macroexpand %%macrocall %%%macro?
      &rest &body &optional &key))

(defun make-keyword (x)
  (values (intern (symbol-name x) "KEYWORD")))

(defun make-keywords (x)
  (mapcar #'make-keyword x))

(defun all-exports ()
  (make-keywords (append +core-variables+
                         +direct-imports+
                         (mapcar #'car +renamed-imports+)
                         +implementations+)))

(defun cl-peek-char (&rest x)
  (apply #'peek-char x))

(defun cl-read-char (&rest x)
  (apply #'read-char x))


;;;; The core package where the action happens.

(defmacro define-core-package ()
  `(defpackage :tre-core
     (:use :common-lisp :tre-init)
     (:shadow :*macroexpand-hook*
              :read :peek-char :read-char)
     (:export ,@(all-exports))))

(define-core-package)

(in-package :tre-core)

;;; Wrapped functions.

(defmacro define-wrappers ()
  `(progn
     ,@(mapcar #'(lambda (x)
                   `(defun ,(values (intern (symbol-name (car x)) "TRE-CORE")) (&rest x)
                      (apply (function ,(cadr x)) x)))
               +renamed-imports+)))

(define-wrappers)

;;; Global variables.

(defvar *universe* nil)
(defvar *variables* nil)
(defvar *defined-functions* nil)
(defvar *environment-path* ".")
(defvar *environment-filenames* nil)
(defvar *quasiquoteexpand-hook* nil)
(defvar *default-listprop* nil)
(defvar *macroexpand-hook* nil)

(defvar *macros* nil)
(defvar *builtins* (make-hash-table :test #'eq))
(defvar *function-sources* (make-hash-table :test #'eq))

;;; Implementations.

(defun cpr (x) x nil)
(defun rplacp (v x) v x)

(defun builtin? (x) (gethash x *builtins*))
(defun macro? (x) (rassoc x *macros* :test #'eq))

(defun =-aref (v x &rest indexes) v x (apply #'aref x indexes))

(defun file-exists? (pathname) pathname (error "Not implemented."))
(defun %fopen (pathname access-mode) pathname access-mode (error "Not implemented."))

(defun quit (x) x (error "Not implemented."))

(defun %malloc (num-bytes) num-bytes (error "Not implemented."))
(defun %malloc-exec (num-bytes) num-bytes (error "Not implemented."))
(defun %free (address) address (error "Not implemented."))
(defun %free-exec (address) address (error "Not implemented."))
(defun %%set (address byte) address byte (error "Not implemented."))
(defun %%get (address) address (error "Not implemented."))

(defun function-native (x) x)
(defun function-bytecode (x) x (error "Not implemented."))
(defun =-function-bytecode (v x) v x (error "Not implemented."))
(defun function-source (x) x (gethash x *function-sources*))
(defun =-function-source (v x) v x (setf (gethash x *function-sources*) v))

(defun bit-or (a b) (bit-or a b))
(defun << (x num-bits-to-left) x num-bits-to-left (error "Not implemented."))
(defun >> (x num-bits-to-right) x num-bits-to-right (error "Not implemented."))

(defun =-symbol-value (x) x (error "Not implemented."))
(defun %setq-atom-value (value symbol) value symbol (error "Not implemented."))
(defun =-symbol-function (x) x (error "Not implemented."))

(defun filter (fun x) (mapcar fun x))
(defun %set-elt (object sequence index) object sequence index (error "Not implemented."))

(defun %fclose (stream-handle) stream-handle (error "Not implemented."))
(defun %directory (pathname) pathname (error "Not implemented."))
(defun %stat (pathname) pathname (error "Not implemented."))
(defun readlink (pathname) pathname (error "Not implemented."))

(defun %terminal-raw () (error "Not implemented."))
(defun %terminal-normal () (error "Not implemented."))
(defun end-debug () (error "Not implemented."))

(defun alien-dlopen (path-to-shared-library) path-to-shared-library (error "Not implemented."))
(defun alien-dlsym (handle) handle (error "Not implemented."))
(defun alien-call (address) address (error "Not implemented."))

(defun open-socket (port-number) port-number (error "Not implemented."))
(defun accept () (error "Not implemented."))
(defun recv () (error "Not implemented."))
(defun send (string) string (error "Not implemented."))
(defun close-connection () (error "Not implemented."))
(defun close-socket () (error "Not implemented."))

(defun %type-id (x) x (error "Not implemented."))
(defun %%id (x) x (error "Not implemented."))
(defun %error (x) x (error x))
(defun %strerror (x) x (error "Not implemented."))
(defun atan2 (x) x (error "Not implemented."))
(defun pow (x) x (error "Not implemented."))
(defun quit (x) x (error "Not implemented."))
(defun %nconc (&rest x) x (apply #'nconc x))
(defun string-concat (&rest x) x (apply #'concatenate 'string x))

(defun %%macroexpand (x)
  (if *macroexpand-hook*
      (funcall *macroexpand-hook* x)
      x))

(defun group (x size)
  (cond
    ((not x) nil)
    ((< (length x) size) (list x))
    (t (cons (subseq x 0 size)
             (group (nthcdr size x) size)))))

(defmacro ? (&body body)
  (let* ((tests (group body 2))
         (end   (car (last tests))))
    (unless body
      (error "Body is missing."))
    `(cond
       ,@(if (= 1 (length end))
             (append (butlast tests) (list (cons t end)))
             tests))))

(defmacro %set-atom-fun (x v) `(setf (symbol-function ',x) ,v))

(defmacro %defvar (name &optional (init nil))
  (print `(%defvar ,name))
  `(progn
     (push ',name *variables*)
     (defvar ,name ,init)))

(defmacro %defun (name args &body body)
  (print `(%defun ,name ,args))
  `(progn
     (push ',name *defined-functions*)
     (defun ,name ,args ,@body)))

(defmacro early-defun (name args &body body)
  `(%defun ,name ,args ,@body))

;; CL only accepts &BODY keywords in macros.
;; We turn tré macros into functions so this does the fixing.
(defun convert-&body (x)
  (mapcar #'(lambda (x) (if (eq '&body x) '&rest x)) x))

(defmacro %defmacro (name args &body body)
  (print `(%defmacro ,name ,args))
  `(push (cons ',name #'(lambda ,(convert-&body args) ,@body)) *macros*))

(defun %%macrocall (x)
  (apply (cdr (assoc (car x) *macros* :test #'eq)) (cdr x)))

(defun %%%macro? (x)
  (assoc x *macros* :test #'eq))

(defun function-expr? (x)
  (and (consp x)
       (eq 'function (car x))
       (not (atom (cadr x)))))

(defun make-cl-lambdas (x)
  (cond
    ((atom x) x)
    ((and (function-expr? (car x)) `(labels ((~ja ,@(make-cl-lambdas (cadar x))))
                                      (~ja ,@(cdr x)))))
    ((function-expr? x) `#'(lambda ,@(make-cl-lambdas (cadr x))))
    (t (mapcar #'make-cl-lambdas x))))

(defun quasiquote-expand (x)
  (if *quasiquoteexpand-hook*
      (funcall *quasiquoteexpand-hook* x)
      x))

(defun %eval (x)
  (eval (make-cl-lambdas (quasiquote-expand (%%macroexpand x)))))

;;; Reader

(load "cl-read.lisp")

;;; Loader

(defun %load-r (s)
  (when (peek-char s)
    (cons (print (read s))
          (%load-r s))))

(defun %load (pathname)
  (print `(%load ,pathname))
  (with-open-file (s pathname)
    (%load-r s)))


;;;; The user package.

(defpackage :tre (:use :tre-core))
(in-package :tre)

(defun macroexpand (x)
  (%%macroexpand x))

(%load "environment/env-load-cl.lisp")
