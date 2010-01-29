;;;;; TRE compiler
;;;;; Copyright (C) 2006-2007,2009 Sven Klose <pixel@copei.de>
;;;;;
;;;;; METACODE FUNCTION INFORMATION
;;;;;
;;;;; This structure contains all information required to generate
;;;;; a native function. They're referenced by %FUNINFO-expressions in
;;;;; metacode-functions.

(defstruct funinfo
  ; Lists of stack variables. The rest contains the parent environments.
  (env nil)
  (env-hash (make-hash-table :test #'eq))
  (used-env nil)

  (name nil)

  (args nil) ; List of arguments.

  (sym (gensym)) ; Symbol of this funinfo used in LAMBDA-expressions.

  (parent niL)

  (ignorance nil)

  ; List of variables defined outside the function.
  (free-vars nil)

  ; Array of local variables passed to child function via ghost argument.
  (lexical nil)
  (ghost niL)

  ; List of symbols exported to child functions
  ; via LEXICAL.
  (lexicals nil)

  ; Number of jump tags in body.
  (num-tags nil)

  ; Function code. The format depends on the compilation pass.
  first-cblock)

(defun funinfo-topmost (fi)
  (aif (funinfo-parent fi)
	   (funinfo-topmost !)
	   fi))
