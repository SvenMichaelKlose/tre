;;;; TRE transpiler
;;;; Copyright (c) 2005-2009 Sven Klose <pixel@copei.de>

(env-load "../transpiler/utils.lisp")
(env-load "../transpiler/config.lisp")

(env-load "../transpiler/codegen/identifier.lisp")
(env-load "../transpiler/codegen/finalize.lisp")
(env-load "../transpiler/codegen/operators.lisp")
(env-load "../transpiler/codegen/macros.lisp")
(env-load "../transpiler/codegen/string-encapsulation.lisp")
(env-load "../transpiler/codegen/obfuscate.lisp")
(env-load "../transpiler/codegen/toplevel.lisp")

(env-load "../transpiler/expand/named-functions.lisp")
(env-load "../transpiler/expand/expression-expand.lisp")
(env-load "../transpiler/expand/argument-definitions.lisp")
(env-load "../transpiler/expand/lambda-expand.lisp")
(env-load "../transpiler/expand/literals.lisp")
(env-load "../transpiler/expand/quote-keywords.lisp")
(env-load "../transpiler/expand/macros.lisp")
(env-load "../transpiler/expand/standard-macros.lisp")
(env-load "../transpiler/expand/toplevel.lisp")

(env-load "../transpiler/import.lisp")
(env-load "../transpiler/toplevel.lisp")

(env-load "../transpiler/javascript/config.lisp")
(env-load "../transpiler/javascript/expand.lisp")
(env-load "../transpiler/javascript/codegen.lisp")
(env-load "../transpiler/javascript/codegen-inline.lisp")
(env-load "../transpiler/javascript/core.lisp")
(env-load "../transpiler/javascript/tests.lisp")
(env-load "../transpiler/javascript/toplevel.lisp")

;(env-load "../transpiler/php/config.lisp")
;(env-load "../transpiler/php/expand.lisp")
;(env-load "../transpiler/php/codegen.lisp")
;(env-load "../transpiler/php/codegen-inline.lisp")
;(env-load "../transpiler/php/core.lisp")
;(env-load "../transpiler/php/toplevel.lisp")

;(env-load "../transpiler/c/config.lisp")
;(env-load "../transpiler/c/expand.lisp")
;(env-load "../transpiler/c/codegen.lisp")
;(env-load "../transpiler/c/core.lisp")
;(env-load "../transpiler/c/toplevel.lisp")
