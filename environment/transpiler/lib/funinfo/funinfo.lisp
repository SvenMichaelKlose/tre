;;;;; tré – Copyright (c) 2006–2013 Sven Michael Klose <pixel@copei.de>

(defvar *funinfo*)

(define-gensym-generator funinfo-sym ~f)

(defstruct funinfo
  (transpiler   nil)
  (parent       nil)
  (name         nil)

  (argdef       nil) ; Argument definition.
  (args         nil) ; Expanded argument definition.
  (body         nil)

  (vars         nil)
  (vars-hash    nil)
  (used-vars    nil)
  (free-vars    nil)
  (places       nil)

  (scoped-vars  nil) ; List of symbols exported to child functions.
  (scope        nil) ; Name of the array of scoped-vars.
  (scope-arg    nil) ; Name of hidden argument with an array of scoped-vars.
  (local-function-args nil)
  (fast-scope?  nil)

  ; Number of jump tags in body.
  (num-tags   nil)
  
  (globals    nil)
  (cps?       nil))

(defun funinfo-topmost (fi)
  (let p (funinfo-parent fi)
    (? (& p (funinfo-parent p))
	   (funinfo-topmost p)
	   fi)))

(defun funinfo-toplevel? (fi)
  (!? (funinfo-parent fi)
      (not (funinfo-parent !))))

(def-funinfo copy-funinfo (funinfo)
  (make-funinfo
      :parent       parent
      :name         name
      :argdef        argdef
      :args         (copy-list args)
      :body         (copy-list body)
      :vars         (copy-list vars)
      :vars-hash    (copy-hash-table vars-hash)
      :used-vars    (copy-list used-vars)
      :free-vars    (copy-list free-vars)
      :places       (copy-list places)
      :scoped-vars  (copy-list scoped-vars)
      :scope        scope
      :scope-arg    scope-arg
      :local-function-args (copy-list local-function-args)
      :fast-scope?  fast-scope?
      :num-tags     num-tags
      :globals      (copy-list globals)
      :cps?         cps?))

(defun get-funinfo (name &optional (tr *transpiler*))
  (& name (href (transpiler-funinfos tr) name)))

(defun get-lambda-funinfo (x)
  (when (named-lambda? x)
    (get-funinfo (lambda-name x))))

(defmacro with-global-funinfo (&rest body)
  `(with-temporary *funinfo* (transpiler-global-funinfo *transpiler*)
     ,@body))

(defmacro with-lambda-funinfo (x &rest body)
  `(with-temporary *funinfo* (get-lambda-funinfo ,x)
     ,@body))

(defun create-funinfo (&key name parent args body (transpiler *transpiler*) (cps? nil))
  (& (href (transpiler-funinfos transpiler) name)
     (error "FUNFINFO for ~A is already memorized." name))
  (with (argnames (argument-expand-names 'lambda-expand args)
         fi       (make-funinfo :name          name
                                :argdef        args
                                :args          argnames
                                :body          body
                                :parent        parent
                                :transpiler    transpiler
                                :cps?          (unless (transpiler-cps-exception? transpiler name)
                                                 cps?)))
    (= (href (transpiler-funinfos transpiler) name) fi)
    (funinfo-var-add fi '~%ret)
    (& (transpiler-copy-arguments-to-stack? transpiler)
       (funinfo-var-add-many fi argnames))
    fi))

(defun funinfo-closure-without-free-vars? (fi)
  (& (funinfo-scope-arg fi)
     (not (funinfo-free-vars fi))))

(defun print-funinfo-sources (tr)
  (filter [(format t "Function ~A:~%" (funinfo-name _))
           (format t "Arguments: ~A~%" (funinfo-argdef _))
           (format t "Body: ~A~%" (funinfo-body _))]
          (hashkeys (transpiler-funinfos tr))))
