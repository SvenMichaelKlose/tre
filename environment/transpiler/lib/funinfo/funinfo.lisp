;;;;; tré – Copyright (c) 2006–2013 Sven Michael Klose <pixel@copei.de>

(defvar *funinfo*)
(defvar *funinfo-sym-counter* 0)

(defun make-funinfo-sym ()
  (alet ($ '~F (1+! *funinfo-sym-counter*))
    (? (& (eq ! (symbol-value !))
          (not (symbol-function !)))
       !
       (make-funinfo-sym))))

(defstruct funinfo
  (transpiler nil)
  (parent nil)
  (name nil) ; Name of the function.

  (argdef nil) ; Argument definition.
  (args nil) ; Expanded argument definition.

  ; Lists of stack variables. The rest contains the parent environments.
  (vars nil)
  (vars-hash nil)
  (used-vars nil)
  (free-vars nil)

  (lexicals nil) ; List of symbols exported to child functions.
  (lexical nil)  ; Name of the array of lexicals.
  (ghost nil)    ; Name of hidden argument with an array of lexicals.
  (local-function-args nil)

  ; List if variables which must not be removed by the optimizer in order
  ; to keep re-assigned arguments out of the GC (see OPT-TAILCALL).
  (immutables nil)

  ; Number of jump tags in body.
  (num-tags nil)
  
  (globals nil)
  (needs-cps? (not *transpiler-except-cps?*)))

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
      :needs-cps?   needs-cps?))

(defun get-funinfo (name &optional (tr *transpiler*))
  (& name (href (transpiler-funinfos tr) name)))

(defun get-lambda-funinfo (x)
  (when (named-lambda? x)
    (get-funinfo (lambda-name x))))

(defun create-funinfo (&key name parent args (transpiler *transpiler*))
  (& (href (transpiler-funinfos transpiler) name)
     (error "Funinfo for ~A already memorized." name))
  (with (argnames (argument-expand-names 'lambda-expand args)
         fi       (make-funinfo :name       name
                                :argdef     args
                                :args       argnames
                                :parent     parent
                                :transpiler transpiler))
    (= (href (transpiler-funinfos transpiler) name) fi)
    (funinfo-var-add fi '~%ret)
    (& (transpiler-copy-arguments-to-stack? transpiler)
       (funinfo-var-add-many fi argnames))
    fi))
