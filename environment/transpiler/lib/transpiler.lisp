; tré – Copyright (c) 2008–2015 Sven Michael Klose <pixel@copei.de>

(defvar *transpiler* nil)
(defvar *transpiler-log* nil)
(defvar *default-transpiler* nil)
(defvar *optional-passes* '(:accumulate-toplevel
                            :inject-debugging
                            :cps
                            :obfuscate))

(defvar *print-executed-functions?* nil)

(defun make-host-functions ()
  (alist-hash (+ *functions* *macros* *builtin-argdefs*) :test #'eq))

(defun make-host-variables ()
  (alist-hash (@ [cons _. t] *variables*) :test #'eq))

(defun make-functionals ()
  (alist-hash (@ [cons _ t] *functionals*) :test #'eq))

(defstruct transpiler
  (:global *transpiler*)
  (name                       nil :not-global)

  ;;;
  ;;; For users.
  ;;;

  ; Include low-level assertions.
  (assert?                    nil)

  ; Backtrace stack at run-time.
  (backtrace?                 nil)

  ; Print identifiers and their obfuscated versions when done.
  (print-obfuscations?        nil)

  ; Measure the time each function needs at run-time.
  ; See also file 'stage3/profile.lisp'.
  (profile?                   nil)

  ; Measure the number of calls in each function at run-time.
  ; See also file 'stage3/profile.lisp'.
  (profile-num-calls?         nil)

  ; Also generate argument expanders for functions with simple
  ; argument lists for optional assertions.
  (always-expand-arguments?   nil)

  ; Import functions from the compile-time host if missing.
  (import-from-host?          t)

  ; Also import global variables from the compile-time host if missing.
  (import-variables?          t)

  ; Only expand macros defined in the compile-time host.
  (only-environment-macros?   t)

  ; Dump outputs of all passes if T.  Might also be a pass name or a list
  ; of names.
  (dump-passes?               nil)

  ; Dump outputs of passes in which this expression is found.
  ; '(FUNCTION BUTLAST) would dump everything related to compiling BUTLAST.
  (dump-selector              nil)

  ; Dump FUNINFOs in comments before their functions.
  (funinfo-comments?          nil)

  ; Used for incremental compilations.  If set only this list of sections
  ; is compiled and the rest is taken from the section caches.
  (sections-to-update         nil)

  ; Associative list of target-dependent configurations.
  (configurations             nil)

  ;;;
  ;;; For targets.
  ;;;

  (disabled-ends           nil)
  (disabled-passes         nil)
  (enabled-passes          nil)
  (output-passes           '((:frontend . :lambda-expand)))

  (frontend-init           nil)
  (middleend-init          nil)

  (identifier-char?        [_ (identity t)])
  (literal-converter       #'identity)
  (gen-string              #'literal-string)
  (postprocessor           #'concat-stringtree)
  (prologue-gen            nil)
  (epilogue-gen            nil)
  (decl-gen                nil)
  (sections-before-import  nil)
  (sections-after-import   nil)
  (ending-sections         nil)

  std-macro-expander
  codegen-expander

  expex-initializer

  (lambda-export?           nil)
  (function-prologues?      t)
  (needs-var-declarations?  nil)
  (stack-locals?            nil)
  (arguments-on-stack?      nil)
  (copy-arguments-to-stack? nil)

  (function-name-prefix     "USERFUN_")

  ;;;
  ;;; Generic
  ;;;

  (expex                    nil)
  (symbol-translations      nil)
  (thisify-classes          (make-hash-table :test #'eq))
  (obfuscations             (make-hash-table :test #'eq))
  (plain-arg-funs           nil)
  (late-symbols             (make-hash-table :test #'eq))
  (exported-closures        nil)
  (delayed-exprs            nil)
  (delayed-var-inits        nil)
  (memorized-sources        nil)

  (funinfos                 (make-hash-table :test #'eq))
  (funinfos-reverse         (make-hash-table :test #'eq))
  (global-funinfo           nil)

  (defined-functions        (make-hash-table :test #'eq))
  (defined-variables        (make-hash-table :test #'eq))
  (literals                 (make-hash-table :test #'eq))
  (host-functions           nil)
  (host-variables           nil)
  (functionals              nil)

  (wanted-functions nil)
  (wanted-functions-hash    (make-hash-table :test #'eq))
  (wanted-variables nil)
  (wanted-variables-hash    (make-hash-table :test #'eq))
  (used-functions           (make-hash-table :test #'eq))

  (accumulated-toplevel-expressions nil)
  (predefined-symbols       nil)

  (cps-exceptions           (make-hash-table :test #'eq))
  (cps-wrappers             (make-hash-table :test #'eq))
  (native-cps-functions     (make-hash-table :test #'eq))

  ; Literals that must be declared or cached before code with them is emitted.
  (compiled-chars           (make-hash-table :test #'==))
  (compiled-numbers         (make-hash-table :test #'==))
  (compiled-strings         (make-hash-table :test #'eq))
  (compiled-symbols         (make-hash-table :test #'eq))
  (compiled-decls           nil)
  (compiled-inits           nil)

  (raw-decls                nil)
  (emitted-decls            nil)
  (imports                  nil)

  (identifiers              (make-hash-table :test #'eq))
  (converted-identifiers    (make-hash-table :test #'eq))

  (cached-frontend-sections nil)
  (cached-output-sections   nil)

  (current-package          nil)
  
  (current-pass             nil)
  (current-section          nil)
  (current-section-data     nil)
  (last-pass-result         nil))

(defun transpiler-reset (tr)
  (= (transpiler-thisify-classes tr)        (make-hash-table :test #'eq)	; thisified classes.
  	 (transpiler-wanted-functions tr)       nil
     (transpiler-wanted-functions-hash tr)  (make-hash-table :test #'eq)
     (transpiler-wanted-variables tr)       nil
     (transpiler-wanted-variables-hash tr)  (make-hash-table :test #'eq)
     (transpiler-defined-functions tr)      (make-hash-table :test #'eq)
     (transpiler-host-functions tr)         (make-host-functions)
     (transpiler-host-variables tr)         (make-host-variables)
     (transpiler-functionals tr)            (make-functionals)
     (transpiler-late-symbols tr)           (make-hash-table :test #'eq)
     (transpiler-identifiers tr)            (make-hash-table :test #'eq)
     (transpiler-converted-identifiers tr)  (make-hash-table :test #'eq)
     (transpiler-exported-closures tr)      nil
     (transpiler-delayed-exprs tr)          nil
     (transpiler-delayed-var-inits tr)      nil
     (transpiler-memorized-sources tr)      nil)
  (transpiler-add-obfuscation-exceptions tr nil (make-symbol ""))
  tr)

(def-transpiler copy-transpiler (transpiler)
  (aprog1
    (make-transpiler
        :name                     name
        :assert?                  assert?
        :backtrace?               backtrace?
        :print-obfuscations?      print-obfuscations?
        :profile?                 profile?
        :profile-num-calls?       profile-num-calls?
        :always-expand-arguments? always-expand-arguments?
        :import-from-host?        import-from-host?
        :import-variables?        import-variables?
        :only-environment-macros? only-environment-macros?
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
        :literal-converter        literal-converter
        :gen-string               gen-string
        :postprocessor            postprocessor
        :prologue-gen             prologue-gen
        :epilogue-gen             epilogue-gen
        :decl-gen                 decl-gen
        :sections-before-import   sections-before-import
        :sections-after-import    sections-after-import
        :ending-sections          ending-sections
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
        :thisify-classes          (copy-hash-table thisify-classes)
        :obfuscations             (copy-hash-table obfuscations)
        :plain-arg-funs           (copy-list plain-arg-funs)
        :late-symbols             (copy-hash-table late-symbols)
        :exported-closures        (copy-list exported-closures)
        :delayed-exprs            (copy-list delayed-exprs)
        :delayed-var-inits        (copy-list delayed-var-inits)
        :memorized-sources        (copy-list memorized-sources)
        :funinfos                 (copy-hash-table funinfos)
        :funinfos-reverse         (copy-hash-table funinfos-reverse)
        :global-funinfo           (& global-funinfo (copy-funinfo global-funinfo))
        :defined-functions        (copy-hash-table defined-functions)
        :defined-variables        (copy-hash-table defined-variables)
        :literals                 (copy-hash-table literals)
        :host-functions           (copy-hash-table host-functions)
        :host-variables           (copy-hash-table host-variables)
        :functionals              (copy-hash-table functionals)
        :wanted-functions         (copy-list wanted-functions)
        :wanted-functions-hash    (copy-hash-table wanted-functions-hash)
        :wanted-variables         (copy-list wanted-variables)
        :wanted-variables-hash    (copy-hash-table wanted-variables-hash)

        :accumulated-toplevel-expressions (copy-list accumulated-toplevel-expressions)
        :predefined-symbols       (copy-list predefined-symbols)

        :cps-exceptions           (copy-hash-table cps-exceptions)
        :cps-wrappers             (copy-hash-table cps-wrappers)
        :native-cps-functions     (copy-hash-table native-cps-functions)

        :compiled-chars           (copy-hash-table compiled-chars)
        :compiled-numbers         (copy-hash-table compiled-numbers)
        :compiled-strings         (copy-hash-table compiled-strings)
        :compiled-symbols         (copy-hash-table compiled-symbols)
        :compiled-decls           (copy-list compiled-decls)
        :compiled-inits           (copy-list compiled-inits)
        :raw-decls                (copy-list raw-decls)
        :emitted-decls            (copy-list emitted-decls)
        :imports                  imports
        :identifiers              (copy-hash-table identifiers)
        :converted-identifiers    (copy-hash-table converted-identifiers)
        :cached-frontend-sections (copy-alist cached-frontend-sections)
        :cached-output-sections   (copy-alist cached-output-sections)
        :current-package          current-package)
    (transpiler-copy-std-macro-expander transpiler !)
    (transpiler-make-expex !)))

(defmacro transpiler-getter-not-global (name &body body)
  `(defun ,($ 'transpiler- name) (tr x)
       ,@body))

(defmacro transpiler-getter (name &body body)
  `(progn
     (transpiler-getter-not-global ,name ,@body)
     (defun ,($ name) (x)
       (let tr *transpiler*
         ,@body))))

(defmacro transpiler-getter-list (name)
  `(transpiler-getter ,($ name '?) (member x (,($ 'transpiler- name 's) tr) :test #'eq)))

(defun transpiler-defined-functions-without-builtins (tr) (remove-if #'builtin? (transpiler-defined-functions tr)))
(transpiler-getter defined-function        (href (transpiler-defined-functions tr) x))
(transpiler-getter defined-variable        (href (transpiler-defined-variables tr) x))
(transpiler-getter literal?                (href (transpiler-literals tr) x))
(transpiler-getter cps-exception?          (href (transpiler-cps-exceptions tr) x))
(transpiler-getter cps-wrapper?            (href (transpiler-cps-wrappers tr) x))
(transpiler-getter native-cps-function?    (href (transpiler-native-cps-functions tr) x))
(transpiler-getter host-function           (href (transpiler-host-functions tr) x))
(transpiler-getter host-function-arguments (car (transpiler-host-function tr x)))
(transpiler-getter host-function-body      (cdr (transpiler-host-function tr x)))
(transpiler-getter host-variable?          (href (transpiler-host-variables tr) x))
(transpiler-getter-not-global function-arguments (car (transpiler-defined-function tr x)))
(transpiler-getter-not-global function-body      (cdr (transpiler-defined-function tr x)))
(transpiler-getter wanted-function?        (href (transpiler-wanted-functions-hash tr) x))
(transpiler-getter wanted-variable?        (href (transpiler-wanted-variables-hash tr) x))
(transpiler-getter late-symbol?            (href (transpiler-late-symbols tr) x))
(progn
  ,@(@ [`(transpiler-getter-list ,_)]
       '(plain-arg-fun emitted-decl)))

(transpiler-getter add-defined-variable  (= (href (transpiler-defined-variables tr) x) t)
                                         x)
(transpiler-getter add-literal           (= (href (transpiler-literals tr) x) t)
                                         x)
(transpiler-getter add-cps-exception     (= (href (transpiler-cps-exceptions tr) x) t)
                                         x)
(transpiler-getter add-cps-wrapper       (= (href (transpiler-cps-wrappers tr) x) t)
                                         x)
(transpiler-getter add-native-cps-function  (= (href (transpiler-native-cps-functions tr) x) t)
                                            x)
(transpiler-getter-not-global macro? (| (expander-has-macro? (transpiler-std-macro-expander tr) x)
                                        (expander-has-macro? (transpiler-codegen-expander tr) x)))
(transpiler-getter imported-variable? (& (transpiler-import-from-host? tr)
                                         (transpiler-host-variable? tr x)))

(defun transpiler-add-defined-function (tr name args body)
  (= (href (transpiler-defined-functions tr) name) (. args body))
  name)

(defun add-defined-function (name args body)
  (transpiler-add-defined-function *transpiler* name args body))

(define-slot-setter-push transpiler-add-exported-closure tr  (transpiler-exported-closures tr))
(define-slot-setter-push transpiler-add-plain-arg-fun tr     (transpiler-plain-arg-funs tr))
(define-slot-setter-push transpiler-add-emitted-decl tr      (transpiler-emitted-decls tr))

(defun add-delayed-expr (x)
  (+! (delayed-exprs) (frontend x))
  nil)

(defun add-delayed-var-init (x)
  (+! (delayed-var-inits) (frontend x))
  nil)

(defun transpiler-add-plain-arg-funs (tr lst)
  (adolist lst
    (transpiler-add-plain-arg-fun tr !)))

(defun transpiler-add-obfuscation-exceptions (tr &rest x)
  (adolist x
	(= (href (transpiler-obfuscations tr) (make-symbol (symbol-name !))) t)))

(defun add-obfuscation-exceptions (&rest x)
  (apply #'transpiler-add-obfuscation-exceptions *transpiler* x))

(defun add-late-symbol (x)
  (= (href (late-symbols) x) t)
  x)

(defun transpiler-macro (tr name)
  (let expander (expander-get (transpiler-codegen-expander tr))
    (funcall (expander-lookup expander) expander name)))

(defun make-global-funinfo (tr)
  (= (transpiler-global-funinfo tr) (create-funinfo :name 'global-scope
                                                    :parent nil
                                                    :args nil
                                                    :body nil
                                                    :transpiler tr)))

(defun package-symbol (x)
  (make-symbol (symbol-name x) (current-package)))

(defun transpiler-add-functional (tr x)
  (= (href (transpiler-functionals tr) x) t))

(defun transpiler-functional? (tr x)
  (href (transpiler-functionals tr) x))

(defun transpiler-defined-symbol? (fi x)
  (| (funinfo-find fi x)
     (function? x)
     (keyword? x)
     (member x (predefined-symbols) :test #'eq)
     (in? x nil t '~%ret 'this)
     (imported-variable? x)
     (defined-function x)
     (defined-variable x)
     (transpiler-macro? *transpiler* x)
     (host-variable? x)
     (late-symbol? x)
     (funinfo-var? (global-funinfo) x)))

(defun add-used-function (x)
  (= (href (used-functions) x) t)
  x)

(defun optional-pass? (x)
  (member x *optional-passes* :test #'eq))

(defun transpiler-disabled-pass? (tr x)
  (member x (transpiler-disabled-passes tr) :test #'eq))

(defun transpiler-enabled-pass? (tr x)
  (? (optional-pass? x)
     (member x (transpiler-enabled-passes tr) :test #'eq)
     (not (transpiler-disabled-pass? tr x))))

(defun enabled-pass? (x)
  (transpiler-enabled-pass? *transpiler* x))

(defun enabled-end? (x)
  (not (member x (disabled-ends) :test #'eq)))

(defun transpiler-enable-pass (tr x)
  (| (symbol? x)
     (error "Pass name must be a symbol, got ~A." x))
  (& (transpiler-enabled-pass? tr x)
     (error "Pass ~A already enabled." x))
  (| (optional-pass? x)
     (error "Pass ~A is not optional or doesn't exist." x))
  (= (transpiler-enabled-passes tr) (. (make-keyword x) (transpiler-enabled-passes tr))))

(defun transpiler-disable-pass (tr x)
  (| (symbol? x)
     (error "Pass name must be a symbol, got ~A." x))
  (& (transpiler-disabled-pass? tr x)
     (error "Pass ~A already disabled." x))
  (& (optional-pass? x)
     (error "Pass ~A is optional. Don't enable it instead of disabling it." x))
  (= (transpiler-disabled-passes tr) (. (make-keyword x) (transpiler-disabled-passes tr))))

(defun configuration-item (x)
  (alet (configurations)
    (| (assoc x ! :test #'eq)
       (error "Transpiler ~A has no configuration item ~A. Available items are ~A."
              (transpiler-name *transpiler*) x (carlist !)))))

(defun configuration (x)
  (cdr (configuration-item x)))

(defun (= configuration) (value x)
  (= (cdr (configuration-item x)) value))

(defun transpiler-make-expex (tr)
  (funcall (transpiler-expex-initializer tr)
           (= (transpiler-expex tr) (make-expex))))

(defun default-configurations ()
  '((:save-sources?)
    (:save-argument-defs-only?)
    (:memorize-sources? . t)))

(defun create-transpiler (&rest args)
  (aprog1 (apply #'make-transpiler args)
	(transpiler-reset !)
    (= (transpiler-assert? !) *assert*)
	(transpiler-make-std-macro-expander !)
	(transpiler-make-code-expander !)
	(transpiler-make-expex !)
    (make-global-funinfo !)
    (transpiler-add-obfuscation-exceptions ! '%%native)))
