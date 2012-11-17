;;;;; tré – Copyright (c) 2006–2012 Sven Michael Klose <pixel@copei.de>

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
  (sym (make-funinfo-sym)) ; Symbol of this funinfo used in LAMBDA-expressions.

  (argdef nil) ; Argument definition.
  (args nil) ; Expanded argument definition.

  ; Lists of stack variables. The rest contains the parent environments.
  (env nil)
  (env-hash nil)
  (used-env nil)

  ; List of variables defined outside the function.
  (free-vars nil)

  (lexicals nil) ; List of symbols exported to child functions.
  (lexical nil)  ; Name of the array of lexicals.
  (ghost nil)    ; Name of hidden argument with an array of lexicals.
  (local-function-args nil)
  (literals nil) ; Literals used in the function.

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
      :parent parent
      :name name
      :sym sym
      :args (copy-list args)
      :env (copy-list env)
      :env-hash (& env-hash (copy-hash-table env-hash))
      :used-env (copy-list used-env)
      :free-vars (copy-list free-vars)
      :lexicals (copy-list lexicals)
      :lexical lexical
      :ghost ghost
      :local-function-args (copy-list local-function-args)
      :immutables (copy-list immutables)
      :num-tags num-tags
      :globals (copy-list globals)
      :needs-cps? needs-cps?))
