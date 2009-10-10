;;;; TRE transpiler
;;;; Copyright (c) 2005-2009 Sven Klose <pixel@copei.de>

(env-load "transpiler/utils.lisp")
(env-load "transpiler/config.lisp")

(env-load "transpiler/codegen/identifier.lisp")
(env-load "transpiler/codegen/finalize.lisp")
(env-load "transpiler/codegen/function-name.lisp")
(env-load "transpiler/codegen/operators.lisp")
(env-load "transpiler/codegen/macros.lisp")
(env-load "transpiler/codegen/string-encapsulation.lisp")
(env-load "transpiler/codegen/obfuscate.lisp")
(env-load "transpiler/codegen/toplevel.lisp")

(env-load "transpiler/expand/newlines.lisp")
(env-load "transpiler/expand/update-funinfos.lisp")
(env-load "transpiler/expand/named-functions.lisp")
(env-load "transpiler/expand/expression-expand.lisp")
(env-load "transpiler/expand/expex-funcalls.lisp")
(env-load "transpiler/expand/expex-funinfo.lisp")
(env-load "transpiler/expand/expex-global-variables.lisp")
(env-load "transpiler/expand/prepare-runtime-argexps.lisp")
(env-load "transpiler/expand/lambda-expand.lisp")
(env-load "transpiler/expand/literals.lisp")
(env-load "transpiler/expand/quote-keywords.lisp")
(env-load "transpiler/expand/macros.lisp")
(env-load "transpiler/expand/standard-macros.lisp")
(env-load "transpiler/expand/toplevel.lisp")

(env-load "transpiler/import.lisp")
(env-load "transpiler/toplevel.lisp")

(env-load "transpiler/backends/c/expex-literals.lisp")
(env-load "transpiler/backends/c/config.lisp")
(env-load "transpiler/backends/c/expand.lisp")
(env-load "transpiler/backends/c/builtin.lisp")
(env-load "transpiler/backends/c/codegen.lisp")
(env-load "transpiler/backends/c/toplevel.lisp")

(env-load "transpiler/backends/javascript/expex.lisp")
(env-load "transpiler/backends/javascript/config.lisp")
(env-load "transpiler/backends/javascript/expand.lisp")
(env-load "transpiler/backends/javascript/codegen.lisp")
(env-load "transpiler/backends/javascript/codegen-inline.lisp")
(env-load "transpiler/backends/javascript/env-load.lisp")
(env-load "transpiler/backends/javascript/tests.lisp")
(env-load "transpiler/backends/javascript/toplevel.lisp")

(env-load "transpiler/backends/php/expex.lisp")
(env-load "transpiler/backends/php/expex-literals.lisp")
(env-load "transpiler/backends/php/config.lisp")
(env-load "transpiler/backends/php/expand.lisp")
(env-load "transpiler/backends/php/codegen.lisp")
(env-load "transpiler/backends/php/codegen-inline.lisp")
(env-load "transpiler/backends/php/core.lisp")
(env-load "transpiler/backends/php/toplevel.lisp")
