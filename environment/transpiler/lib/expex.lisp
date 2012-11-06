;;;;; tré - Copyright (c) 2006-2012 Sven Michael Klose <pixel@copei.de>

(defstruct expex
  (transpiler nil)

  ; Callback to check if an object is a function.
  (functionp [function? (symbol-value _)])

  ; Callback to get the argument definition of a function.
  (function-arguments #'function-arguments)

  ; Callback to collect used functions.
  (function-collector #'((fun args)))

  ; Callback to collect used variables.
  (argument-filter #'((var) var))

  (setter-filter #'((var) var))

  (expr-filter #'transpiler-import-from-expex)

  (plain-arg-fun? #'((var)))

  (inline? #'((x)))
  (move-lexicals? nil))

(def-expex copy-expex (expex tr)
  (make-expex
      :transpiler tr
      :functionp functionp
      :function-arguments function-arguments
      :function-collector function-collector
      :argument-filter argument-filter
      :setter-filter setter-filter
      :expr-filter expr-filter
      :plain-arg-fun? plain-arg-fun?
      :inline? inline?
      :move-lexicals? move-lexicals?))
