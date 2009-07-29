(defun say-hello ())

(defun fnord ()
;#'c-transpile
  ,@*functions-after-stage-3*
  #'reverse #'append #'tree-list #'find #'assoc #'href #'%macroexpand #'position #'mapcan
  #'argument-expand #'lambda-expand #'expression--expand #'place-expand
  #'opt-peephole
  #'opt-inline
  #'transpiler-quote-keywords
  #'thisify
  #'rename-function-arguments
  #'quasiquote-expand
  #'backquote-expand
  #'simple-quote-expand
  #'dot-expand
  #'concat-stringtree
  #'transpiler-to-string
  #'transpiler-finalize-sexprs
  #'transpiler-encapsulate-strings
  #'transpiler-obfuscate
  #'read
  #'late-print
)
;  #'transpiler-add-wanted-variable
;  #'transpiler-add-wanted-function
;  #'transpiler-import-exported-closures
;  #'transpiler-import-wanted-functions
;  #'transpiler-import-wanted-variables
;  #'transpiler-import-from-environment
;  #'transpiler-import-from-expex
;  #'transpiler-make-expex
;  #'transpiler-make-named-functions
;  #'transpiler-update-funinfo
;  #'transpiler-expression-expand
;  #'transpiler-argument-definitions
;  #'special-form-expand
