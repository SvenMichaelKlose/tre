(defun say-hello ())

(defun fnord ()
;#'c-transpile
  #'reverse #'append #'tree-list #'find #'assoc #'href #'%macroexpand #'position #'mapcan
  #'argument-expand #'lambda-expand #'expression--expand #'place-expand
  #'opt-peephole
;  #'transpiler-make-named-functions
;  #'transpiler-update-funinfo
  #'transpiler-quote-keywords
;  #'transpiler-expression-expand
;  #'transpiler-argument-definitions
  #'thisify
  #'rename-double-function-args
;  #'special-form-expand
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
;  #'transpiler-add-wanted-variable
;  #'transpiler-add-wanted-function
;  #'transpiler-import-exported-closures
;  #'transpiler-import-wanted-functions
;  #'transpiler-import-wanted-variables
;  #'transpiler-import-from-environment
;  #'transpiler-import-from-expex
;  #'transpiler-make-expex
)
