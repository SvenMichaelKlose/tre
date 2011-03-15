;;;;; TRE compiler
;;;;; Copyright (C) 2006-2010 Sven Klose <pixel@copei.de>
;;;;;
;;;;; METACODE FUNCTION INFORMATION
;;;;;
;;;;; This structure contains all information required to generate
;;;;; a native function. They're referenced by %FUNINFO-expressions in
;;;;; metacode-functions.
;;;;;
;;;;; A LAMBDA-expression with a FUNFINFO has the following format:
;;;;;	(function (%FUNINFO <symbol-associated-with-funinfo>
;;;;;			   argument-list . body))

(defstruct funinfo
  (parent nil)
  (name nil) ; Name of the function.
  (sym (gensym)) ; Symbol of this funinfo used in LAMBDA-expressions.

  (args nil) ; List of arguments.

  ; Lists of stack variables. The rest contains the parent environments.
  (env nil)
  (env-hash (make-hash-table :test #'eq))
  (used-env nil)

  ; List of variables defined outside the function.
  (free-vars nil)

  (lexicals nil) ; List of symbols exported to child functions.
  (lexical nil)  ; Name of the array of lexicals.
  (ghost nil)    ; Name of hidden argument with an array of lexicals.

  ; List if variables which must not be removed by the optimizer in order
  ; to keep re-assigned arguments out of the GC (see OPT-TAILCALL).
  (immutables nil)

  ; Number of jump tags in body.
  (num-tags nil)
  
  (globals nil)
  (needs-cps? (not *transpiler-except-cps?*)))

(defun funinfo-topmost (fi)
  (let p (funinfo-parent fi)
    (if (and p
			 (funinfo-parent p))
	   (funinfo-topmost p)
	   fi)))
