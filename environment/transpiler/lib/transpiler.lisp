(var *transpiler* nil)
(var *transpiler-log* nil)
(var *default-transpiler* nil)

(const *optional-passes* '(:accumulate-toplevel))

(fn make-host-functions ()
  (alist-hash (+ *functions*
                 (@ [. _. (cadr _)] *macros*)
                 *builtin-argdefs*)
              :test #'eq))

(fn make-host-variables ()
  (alist-hash (@ [. _. t] *variables*) :test #'eq))

(fn make-functionals ()
  (alist-hash (@ [. _ t] *functionals*) :test #'eq))

(defstruct transpiler
  (:global *transpiler*)
  (name                       nil :not-global)

  ;;;
  ;;; For users.
  ;;;

  ; Also generate argument expanders for functions with simple argument
  ; lists to validate all calls at run-time.
  (always-expand-arguments?   nil)

  ; Import functions from host if missing.
  (import-from-host?          t)

  ; Import global variables from host if missing.
  (import-variables?          t)

  ; Dump outputs of all passes if T.  Might also be a pass name or a list
  ; of names.
  (dump-passes?               nil)

  ; Dump outputs of passes in which this expression is found.
  ; '(FUNCTION BUTLAST) would dump every pass result containing
  ; symbol BUTLAST.
  (dump-selector              nil)

  ; Dump FUNINFOs in comments before their functions.
  (funinfo-comments?          nil)

  ; Used for incremental compilations.  If set only this list of sections
  ; is compiled and the rest is taken from the cache.
  (sections-to-update         nil)

  ; Include assertions.
  (assert?                    nil)

  ; Trace call stack at run-time.
  (backtrace?                 nil)

  ; Associative list of target-dependent configurations.
  (configurations             nil)

  ;;;
  ;;; For targets.
  ;;;

  (disabled-ends           nil)
  (disabled-passes         nil)
  (enabled-passes          nil)
  (output-passes           '((:frontend . :lambda-expand)))

  (frontend-init           #'(()))
  (middleend-init          #'(()))

  (identifier-char?        [_ (identity t)])
  (gen-string              #'literal-string)

  ; The very last pass.
  (postprocessor           #'concat-stringtree)

  ; Prologue/epilogue of generated source.
  (prologue-gen            #'(()))
  (epilogue-gen            #'(()))

  (sections-before-import  #'(()))
  (sections-after-import   #'(()))

  transpiler-macro-expander
  codegen-expander

  (expex-initializer       #'identity)

  (lambda-export?           nil)
  (function-prologues?      t)
  (needs-var-declarations?  nil)
  (stack-locals?            nil)
  (arguments-on-stack?      nil)
  (copy-arguments-to-stack? nil)

  (function-name-prefix     "tre_")

  ;;;
  ;;; Generic
  ;;;

  ; Class EXPEX object to configure EXPRESSION-EXPAND.
  (expex                    nil)

  ; Symbol to identifier translations that override CONVERT-IDENTIFIER,
  ; e.g. to translate NIL to "false" and T to "true".
  (symbol-translations      nil)

  ; Closures cut out of their parent functions.
  (closures                 nil)

  ; Declarations that appear right after the imports.
  (delayed-exprs            nil)

  ; DEFUN function sources.
  (memorized-sources        nil)

  ; FUNINFOs by function name.
  (funinfos                 (make-hash-table :test #'eq))

  ; The root of the FUNINFO tree.
  (global-funinfo           nil)

  (defined-functions        (make-hash-table :test #'eq))
  (defined-variables        (make-hash-table :test #'eq))
  (defined-packages         (make-hash-table :test #'eq))

  ; Defined CLASSes.
  (defined-classes          (make-hash-table :test #'eq))

  (host-functions           nil)
  (host-variables           nil)
  (functionals              nil)

  ; Functions and variables we want to import.  Imports
  ; take place after running everything through the front
  ; end.
  (wanted-functions nil)
  (wanted-functions-hash    (make-hash-table :test #'eq))
  (wanted-variables nil)
  (wanted-variables-hash    (make-hash-table :test #'eq))

  ; List of used functions to warn about unused functions
  ; at the end of COMPILE.
  (used-functions           (make-hash-table :test #'eq))

  (accumulated-toplevel-expressions nil)

  (compiled-symbols         (make-hash-table :test #'eq))
  (compiled-decls           nil)
  (compiled-inits           nil)

  ; Identifier conversions.
  (identifiers              (make-hash-table :test #'eq))

  ; Reversed conversions to detect clashes.
  (converted-identifiers    (make-hash-table :test #'eq))
  (real-function-names      (make-hash-table :test #'eq))

  (cached-frontend-sections nil)
  (cached-output-sections   nil)

  (last-pass-result         nil))

(fn transpiler-reset (tr)
  (= (transpiler-defined-classes tr)        (make-hash-table :test #'eq)
     (transpiler-wanted-functions tr)       nil
     (transpiler-wanted-functions-hash tr)  (make-hash-table :test #'eq)
     (transpiler-wanted-variables tr)       nil
     (transpiler-wanted-variables-hash tr)  (make-hash-table :test #'eq)
     (transpiler-defined-functions tr)      (make-hash-table :test #'eq)
     (transpiler-host-functions tr)         (make-host-functions)
     (transpiler-host-variables tr)         (make-host-variables)
     (transpiler-functionals tr)            (make-functionals)
     (transpiler-identifiers tr)            (make-hash-table :test #'eq)
     (transpiler-converted-identifiers tr)  (make-hash-table :test #'eq)
     (transpiler-real-function-names tr)    (make-hash-table :test #'eq)
     (transpiler-closures tr)               nil
     (transpiler-delayed-exprs tr)          nil
     (transpiler-memorized-sources tr)      nil)
  tr)

(def-transpiler copy-transpiler (transpiler)
  (aprog1
    (make-transpiler
        :name                     name
        :assert?                  assert?
        :backtrace?               backtrace?
        :always-expand-arguments? always-expand-arguments?
        :import-from-host?        import-from-host?
        :import-variables?        import-variables?
        :dump-passes?             dump-passes?
        :funinfo-comments?        funinfo-comments?
        :sections-to-update       (copy-list sections-to-update)
        :configurations           (copy-alist configurations)

        :disabled-ends            (copy-list (ensure-list disabled-ends))
        :disabled-passes          (copy-list (ensure-list disabled-passes))
        :enabled-passes           (copy-list (ensure-list enabled-passes))
        :output-passes            (copy-alist output-passes)
        :frontend-init            frontend-init
        :middleend-init           middleend-init
        :identifier-char?         identifier-char?
        :gen-string               gen-string
        :postprocessor            postprocessor
        :prologue-gen             prologue-gen
        :epilogue-gen             epilogue-gen
        :sections-before-import   sections-before-import
        :sections-after-import    sections-after-import
        :codegen-expander         codegen-expander
        :expex-initializer        expex-initializer
        :lambda-export?           lambda-export?
        :function-prologues?      function-prologues?
        :needs-var-declarations?  needs-var-declarations?
        :stack-locals?            stack-locals?
        :arguments-on-stack?      arguments-on-stack?
        :copy-arguments-to-stack? copy-arguments-to-stack?
        :function-name-prefix     function-name-prefix

        :symbol-translations      (copy-list symbol-translations)
        :defined-classes          (copy-hash-table defined-classes)
        :closures                 (copy-list closures)
        :delayed-exprs            (copy-list delayed-exprs)
        :memorized-sources        (copy-list memorized-sources)
        :funinfos                 (copy-hash-table funinfos)
        :global-funinfo           (& global-funinfo (copy-funinfo global-funinfo))
        :defined-functions        (copy-hash-table defined-functions)
        :defined-variables        (copy-hash-table defined-variables)
        :defined-packages         (copy-hash-table defined-packages)
        :host-functions           (copy-hash-table host-functions)
        :host-variables           (copy-hash-table host-variables)
        :functionals              (copy-hash-table functionals)
        :wanted-functions         (copy-list wanted-functions)
        :wanted-functions-hash    (copy-hash-table wanted-functions-hash)
        :wanted-variables         (copy-list wanted-variables)
        :wanted-variables-hash    (copy-hash-table wanted-variables-hash)

        :accumulated-toplevel-expressions (copy-list accumulated-toplevel-expressions)

        :compiled-symbols         (copy-hash-table compiled-symbols)
        :compiled-decls           (copy-list compiled-decls)
        :compiled-inits           (copy-list compiled-inits)
        :identifiers              (copy-hash-table identifiers)
        :converted-identifiers    (copy-hash-table converted-identifiers)
        :real-function-names      (copy-hash-table real-function-names)
        :cached-frontend-sections (copy-alist cached-frontend-sections)
        :cached-output-sections   (copy-alist cached-output-sections))
    (copy-transpiler-macro-expander transpiler !)
    (transpiler-make-expex !)))

(defmacro transpiler-getter-not-global (name &body body)
  `(fn ,($ 'transpiler- name) (tr x)
       ,@body))

(defmacro transpiler-getter (name &body body)
  `{(transpiler-getter-not-global ,name ,@body)
    (fn ,($ name) (x)
      (let tr *transpiler*
        ,@body))})

(fn transpiler-defined-functions-without-builtins (tr) (remove-if #'builtin? (transpiler-defined-functions tr)))
(transpiler-getter defined-function        (href (transpiler-defined-functions tr) x))
(transpiler-getter defined-variable        (href (transpiler-defined-variables tr) x))
(transpiler-getter defined-package         (href (transpiler-defined-variables tr) x))
(transpiler-getter host-function           (href (transpiler-host-functions tr) x))
(transpiler-getter host-function-arguments (car (transpiler-host-function tr x)))
(transpiler-getter host-function-body      (cdr (transpiler-host-function tr x)))
(transpiler-getter host-variable?          (href (transpiler-host-variables tr) x))
(transpiler-getter-not-global function-arguments (car (transpiler-defined-function tr x)))
(transpiler-getter-not-global function-body      (cdr (transpiler-defined-function tr x)))
(transpiler-getter wanted-function?        (href (transpiler-wanted-functions-hash tr) x))
(transpiler-getter wanted-variable?        (href (transpiler-wanted-variables-hash tr) x))

(transpiler-getter add-defined-variable  (= (href (transpiler-defined-variables tr) x) t)
                                         x)
(transpiler-getter add-defined-package   (= (href (transpiler-defined-packages tr) x) t)
                                         x)
(transpiler-getter-not-global macro? (| (expander-has-macro? (transpiler-transpiler-macro-expander tr) x)
                                        (expander-has-macro? (transpiler-codegen-expander tr) x)))
(transpiler-getter imported-variable? (& (transpiler-import-from-host? tr)
                                         (transpiler-host-variable? tr x)))

(fn transpiler-add-defined-function (tr name args body)
  (= (href (transpiler-defined-functions tr) name) (. args body))
  name)

(fn add-defined-function (name args body)
  (transpiler-add-defined-function *transpiler* name args body))

(define-slot-setter-push transpiler-add-closure tr
  (transpiler-closures tr))

(fn add-delayed-expr (x)
  (+! (delayed-exprs) (frontend (list x)))
  nil)

(fn add-toplevel-expression (x)
  (push x (accumulated-toplevel-expressions)))

(fn make-global-funinfo (tr)
  (= (transpiler-global-funinfo tr) (create-funinfo :name        'global-scope
                                                    :parent      nil
                                                    :args        nil
                                                    :transpiler  tr)))

(fn transpiler-add-functional (tr x)
  (= (href (transpiler-functionals tr) x) t))

(fn transpiler-functional? (tr x)
  (href (transpiler-functionals tr) x))

(fn add-used-function (x)
  (= (href (used-functions) x) t)
  x)

(fn optional-pass? (x)
  (member x *optional-passes* :test #'eq))

(fn transpiler-disabled-pass? (tr x)
  (member x (transpiler-disabled-passes tr) :test #'eq))

(fn transpiler-enabled-pass? (tr x)
  (? (optional-pass? x)
     (member x (transpiler-enabled-passes tr) :test #'eq)
     (not (transpiler-disabled-pass? tr x))))

(fn enabled-pass? (x)
  (transpiler-enabled-pass? *transpiler* x))

(fn enabled-end? (x)
  (not (member x (disabled-ends) :test #'eq)))

(fn transpiler-enable-pass (tr x)
  (| (symbol? x)
     (error "Pass name must be a symbol, got ~A." x))
  (& (transpiler-enabled-pass? tr x)
     (error "Pass ~A already enabled." x))
  (| (optional-pass? x)
     (error "Pass ~A is not optional or doesn't exist." x))
  (= (transpiler-enabled-passes tr)
     (. (make-keyword x) (transpiler-enabled-passes tr))))

(fn transpiler-disable-pass (tr x)
  (| (symbol? x)
     (error "Pass name must be a symbol, got ~A." x))
  (& (transpiler-disabled-pass? tr x)
     (error "Pass ~A already disabled." x))
  (& (optional-pass? x)
     (error "Pass ~A is optional. Don't enable it instead of disabling it." x))
  (= (transpiler-disabled-passes tr)
     (. (make-keyword x) (transpiler-disabled-passes tr))))

(fn transpiler-configuration-item (tr x)
  (!= (transpiler-configurations tr)
    (| (assoc x ! :test #'eq)
       (error "Transpiler ~A has no configuration item ~A. Available items are ~A."
              (transpiler-name tr) x (carlist !)))))

(fn transpiler-configuration (tr x)
  (cdr (transpiler-configuration-item tr x)))

(fn (= transpiler-configuration) (value tr x)
  (= (cdr (transpiler-configuration-item tr x)) value))

(fn configuration-item (x)
  (transpiler-configuration-item *transpiler* x))

(fn (= configuration) (value x)
  (= (transpiler-configuration *transpiler* x) value))

(fn configuration (x)
  (transpiler-configuration *transpiler* x))

(fn transpiler-make-expex (tr)
  (funcall (transpiler-expex-initializer tr)
           (= (transpiler-expex tr) (make-expex))))

(fn default-configurations ()
  '((:save-sources?)
    (:save-argument-defs-only?)
    (:memorize-sources? . t)))

(fn create-transpiler (&rest args)
  (aprog1 (apply #'make-transpiler args)
    (transpiler-reset !)
    (= (transpiler-assert? !) *assert?*)
    (= (transpiler-transpiler-macro-expander !) (make-transpiler-macro-expander !))
    (make-transpiler-codegen-expander !)
    (transpiler-make-expex !)
    (make-global-funinfo !)))
