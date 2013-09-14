;;;;; tré – Copyright (c) 2006–2013 Sven Michael Klose <pixel@copei.de>

(defvar *funinfo*)
(defvar *funinfo-sym-counter* 0)

(defun make-funinfo-sym ()
  (alet ($ '~F (++! *funinfo-sym-counter*))
    (? (& (eq ! (symbol-value !))
          (not (symbol-function !)))
       !
       (make-funinfo-sym))))

(defstruct funinfo
  (transpiler nil)
  (parent     nil)
  (name       nil)

  (argdef     nil) ; Argument definition.
  (args       nil) ; Expanded argument definition.
  (body       nil)

  (vars       nil)
  (vars-hash  nil)
  (used-vars  nil)
  (free-vars  nil)

  (lexicals   nil) ; List of symbols exported to child functions.
  (lexical    nil) ; Name of the array of lexicals.
  (ghost      nil) ; Name of hidden argument with an array of lexicals.
  (local-function-args nil)

  ; List if variables which must not be removed by the optimizer in order
  ; to keep re-assigned arguments out of the GC (see OPT-TAILCALL).
  (immutables nil)

  ; Number of jump tags in body.
  (num-tags   nil)
  
  (globals    nil)
  (cps?       nil))

(defun funinfo-topmost (fi)
  (let p (funinfo-parent fi)
    (? (& p (funinfo-parent p))
	   (funinfo-topmost p)
	   fi)))

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
      :lexicals     (copy-list lexicals)
      :lexical      lexical
      :ghost        ghost
      :local-function-args (copy-list local-function-args)
      :immutables   (copy-list immutables)
      :num-tags     num-tags
      :globals      (copy-list globals)
      :cps?         cps?))

(defun get-funinfo (name &optional (tr *transpiler*))
  (& name (href (transpiler-funinfos tr) name)))

(defun get-lambda-funinfo (x)
  (when (named-lambda? x)
    (get-funinfo (lambda-name x))))

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
                                :cps?          cps?))
    (= (href (transpiler-funinfos transpiler) name) fi)
    (funinfo-var-add fi '~%ret)
    (& (transpiler-copy-arguments-to-stack? transpiler)
       (funinfo-var-add-many fi argnames))
    fi))

(defun print-funinfo-sources (tr)
  (filter [(format t "Function ~A:~%" (funinfo-name _))
           (format t "Arguments: ~A~%" (funinfo-argdef _))
           (format t "Body: ~A~%" (funinfo-body _))]
          (hashkeys (transpiler-funinfos tr))))
