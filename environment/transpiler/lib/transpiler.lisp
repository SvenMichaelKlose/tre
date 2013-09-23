;;;;; tré – Copyright (c) 2008–2013 Sven Michael Klose <pixel@copei.de>

(defvar *transpiler* nil)
(defvar *transpiler-log* nil)
(defvar *transpiler-no-stream?* nil)

(defvar *recompiling?* nil)
(defvar *print-executed-functions?* nil)

(defun make-host-functions-and-macros-hash ()
  (filter [cons _ (function-arguments (symbol-function _))]
          (+ *defined-functions* *macros*)))

(defun make-host-functions-hash ()
  (alist-hash (+ (make-host-functions-and-macros-hash)
                 *builtin-argdefs*)
              :test #'eq))

(defun make-host-variables-hash ()
  (alist-hash (filter [cons _. t] *variables*) :test #'eq))

(defun make-functionals-hash ()
  (alist-hash (filter [cons _ t] *functionals*) :test #'eq))

(defstruct transpiler
  name
  std-macro-expander
  codegen-expander
  separator

  (identifier-char?         [identity t])
  (literal-converter        #'identity)

  expex
  expex-initializer

  (defined-functions-hash   (make-hash-table :test #'eq))
  (defined-variables-hash   (make-hash-table :test #'eq))
  (cps-functions-hash       (make-hash-table :test #'eq))
  (host-functions-hash      nil)
  (host-variables-hash      nil)
  (functionals-hash         nil)

  ; Functions to be imported from the environment.
  (wanted-functions nil)
  (wanted-functions-hash    (make-hash-table :test #'eq))

  (wanted-variables nil)
  (wanted-variables-hash    (make-hash-table :test #'eq))

  (used-functions           (make-hash-table :test #'eq))

  (assert?                  nil)
  (obfuscate?               nil)
  (import-from-environment? t)
  (only-environment-macros? t)
  (save-sources?            nil)
  (save-argument-defs-only? nil)
  (profile?                 nil)
  (profile-num-calls?       nil)
  (warn-on-unused-symbols?  nil)
  (backtrace?               nil)
  (expex-warnings?          t)
  (function-prologues?      t)
  (exclude-base?            nil)

  (gen-string               #'literal-string)

  (lambda-export?           nil)

  (accumulate-toplevel-expressions? nil)
  (accumulated-toplevel-expressions nil)

  (function-name-prefix     "USERFUN_")
  (needs-var-declarations?  nil)

  (stack-locals?            nil)
  (arguments-on-stack?      nil)
  (copy-arguments-to-stack? nil)

  (cps-transformation?      nil)

  (code-concatenator        #'concat-stringtree)
  (make-text?               t)
  (encapsulate-strings?     t)
  (dump-passes?             nil)
  (inject-debugging?        nil)

  (predefined-symbols       nil)

  ;;;
  ;;; You mustn't init these.
  ;;;

  (symbol-translations      nil)
  (thisify-classes          (make-hash-table :test #'eq))
  (function-args            (make-hash-table :test #'eq))
  (function-bodies          (make-hash-table :test #'eq))
  (obfuscations             (make-hash-table :test #'eq))
  plain-arg-funs
  (late-symbols             (make-hash-table :test #'eq))
  (exported-closures        nil)
  (delayed-var-inits        nil)
  (dot-expand?              t)
  (raw-constructor-names?   nil)
  (memorized-sources        nil)
  (memorize-sources?        t)

  (funinfos                 (make-hash-table :test #'eq))
  (funinfos-reverse         (make-hash-table :test #'eq))
  (global-funinfo           nil)

  ; Literals that must be declared or cached before code with them is emitted.
  (compiled-chars           (make-hash-table :test #'==))
  (compiled-numbers         (make-hash-table :test #'==))
  (compiled-strings         (make-hash-table :test #'eq))
  (compiled-symbols         (make-hash-table :test #'eq))
  (compiled-decls           nil)
  (compiled-inits           nil)
  (emitted-decls            nil)
  (imported-deps            "")

  (raw-decls                nil)

  (identifiers              (make-hash-table :test #'eq))
  (converted-identifiers    (make-hash-table :test #'eq))

  ; Recompiling
  (frontend-files)
  (compiled-files)

  (current-package          nil)
  
  (current-pass             nil)
  (current-section          nil)
  (current-section-data     nil)
  (last-pass-result         nil)
  
  (cpr-count?               nil))

(defun transpiler-reset (tr)
  (= (transpiler-thisify-classes tr)        (make-hash-table :test #'eq)	; thisified classes.
  	 (transpiler-wanted-functions tr)       nil
  	 (transpiler-wanted-functions-hash tr)  (make-hash-table :test #'eq)
  	 (transpiler-wanted-variables tr)       nil
  	 (transpiler-wanted-variables-hash tr)  (make-hash-table :test #'eq)
  	 (transpiler-defined-functions-hash tr) (make-hash-table :test #'eq)
  	 (transpiler-host-functions-hash tr)    (make-host-functions-hash)
  	 (transpiler-host-variables-hash tr)    (make-host-variables-hash)
  	 (transpiler-functionals-hash tr)       (make-functionals-hash)
  	 (transpiler-function-args tr)          (make-hash-table :test #'eq)
  	 (transpiler-function-bodies tr)        (make-hash-table :test #'eq)
  	 (transpiler-late-symbols tr)           (make-hash-table :test #'eq)
  	 (transpiler-identifiers tr)            (make-hash-table :test #'eq)
  	 (transpiler-converted-identifiers tr)  (make-hash-table :test #'eq)
  	 (transpiler-exported-closures tr)      nil
  	 (transpiler-delayed-var-inits tr)      nil
     (transpiler-memorized-sources tr)      nil
     (transpiler-memorize-sources? tr)      t)
  (transpiler-add-obfuscation-exceptions tr nil (make-symbol ""))
  tr)

(def-transpiler copy-transpiler (transpiler)
  (aprog1
    (make-transpiler
        :name                   name
        :codegen-expander       codegen-expander
        :separator              separator
        :identifier-char?       identifier-char?
        :literal-converter      literal-converter
        :defined-functions-hash (copy-hash-table defined-functions-hash)
        :defined-variables-hash (copy-hash-table defined-variables-hash)
        :cps-functions-hash     (copy-hash-table cps-functions-hash )
        :host-functions-hash    (copy-hash-table host-functions-hash)
        :host-variables-hash    (copy-hash-table host-variables-hash)
        :functionals-hash       (copy-hash-table functionals-hash)
        :wanted-functions       (copy-list wanted-functions)
        :wanted-functions-hash  (copy-hash-table wanted-functions-hash)
        :wanted-variables       (copy-list wanted-variables)
        :wanted-variables-hash  (copy-hash-table wanted-variables-hash)
        :assert?                assert?
        :obfuscate?             obfuscate?
        :import-from-environment? import-from-environment?
        :only-environment-macros? only-environment-macros?
        :save-sources?           save-sources?
        :save-argument-defs-only? save-argument-defs-only?
        :profile?                profile?
        :profile-num-calls?      profile-num-calls?
        :warn-on-unused-symbols? warn-on-unused-symbols?
        :backtrace?              backtrace?
        :expex-warnings?         expex-warnings?
        :function-prologues?     function-prologues?
        :exclude-base?           exclude-base?
        :gen-string              gen-string
        :lambda-export?          lambda-export?
        :accumulate-toplevel-expressions? accumulate-toplevel-expressions?
        :accumulated-toplevel-expressions (copy-list accumulated-toplevel-expressions)
        :function-name-prefix    function-name-prefix
        :needs-var-declarations? needs-var-declarations?
        :stack-locals?           stack-locals?
        :arguments-on-stack?     arguments-on-stack?
        :copy-arguments-to-stack? copy-arguments-to-stack?
        :cps-transformation?     cps-transformation?
        :code-concatenator       code-concatenator
        :make-text?              make-text?
        :encapsulate-strings?    encapsulate-strings?
        :dump-passes?            dump-passes?
        :inject-debugging?       inject-debugging?
        :symbol-translations     (copy-list symbol-translations)
        :thisify-classes         (copy-hash-table thisify-classes)
        :function-args           (copy-hash-table function-args)
        :function-bodies         (copy-hash-table function-bodies)
        :obfuscations            (copy-hash-table obfuscations)
        :plain-arg-funs          (copy-list plain-arg-funs)
        :late-symbols            (copy-hash-table late-symbols)
        :exported-closures       (copy-list exported-closures)
        :delayed-var-inits       (copy-list delayed-var-inits)
        :dot-expand?             dot-expand?
        :raw-constructor-names?  raw-constructor-names?
        :memorized-sources       (copy-list memorized-sources)
        :memorize-sources?       memorize-sources?
        :predefined-symbols      (copy-list predefined-symbols)
        :funinfos                (copy-hash-table funinfos)
        :funinfos-reverse        (copy-hash-table funinfos-reverse)
        :global-funinfo          (& global-funinfo (copy-funinfo global-funinfo))
        :compiled-chars          (copy-hash-table compiled-chars)
        :compiled-numbers        (copy-hash-table compiled-numbers)
        :compiled-strings        (copy-hash-table compiled-strings)
        :compiled-symbols        (copy-hash-table compiled-symbols)
        :compiled-decls          (copy-list compiled-decls)
        :compiled-inits          (copy-list compiled-inits)
        :emitted-decls           (copy-list emitted-decls)
        :imported-deps           imported-deps
        :raw-decls               (copy-list raw-decls)
        :frontend-files          (copy-alist frontend-files)
        :compiled-files          (copy-alist compiled-files)
        :current-package         current-package
        :identifiers             (copy-hash-table identifiers)
        :converted-identifiers   (copy-hash-table converted-identifiers)
        :expex-initializer       expex-initializer
        :cpr-count?              cpr-count?)
    (transpiler-copy-std-macro-expander transpiler !)
    (transpiler-make-expex !)))

(defmacro transpiler-getter (name &rest body)
  `(defun ,($ 'transpiler- name) (tr x)
     ,@body))

(defmacro transpiler-getter-list (name)
  `(transpiler-getter ,($ name '?) (member x (,($ 'transpiler- name 's) tr) :test #'eq)))

(defun transpiler-defined-functions (tr) (hashkeys (transpiler-defined-functions-hash tr)))
(defun transpiler-defined-functions-without-builtins (tr) (remove-if #'builtin? (transpiler-defined-functions tr)))
(transpiler-getter defined-function        (href (transpiler-defined-functions-hash tr) x))
(transpiler-getter defined-variable        (href (transpiler-defined-variables-hash tr) x))
(transpiler-getter cps-function?           (href (transpiler-defined-variables-hash tr) x))
(transpiler-getter host-function?          (href (transpiler-host-functions-hash tr) x))
(transpiler-getter host-function-arguments (href (transpiler-host-functions-hash tr) x))
(transpiler-getter host-variable?          (href (transpiler-host-variables-hash tr) x))
(transpiler-getter function-body           (href (transpiler-function-bodies tr) x))
(transpiler-getter function-arguments      (href (transpiler-function-args tr) x))
(transpiler-getter wanted-function?        (href (transpiler-wanted-functions-hash tr) x))
(transpiler-getter wanted-variable?        (href (transpiler-wanted-variables-hash tr) x))
(transpiler-getter late-symbol?            (href (transpiler-late-symbols tr) x))
(progn
  ,@(filter  [`(transpiler-getter-list ,_)]
            '(plain-arg-fun emitted-decl)))

(transpiler-getter add-defined-variable (= (href (transpiler-defined-variables-hash tr) x) t)
                                        x)
(transpiler-getter add-cps-function     (= (href (transpiler-cps-functions-hash tr) x) t)
                                        x)
(transpiler-getter switch-obfuscator (= (transpiler-obfuscate? tr) x))
(transpiler-getter macro? (| (expander-has-macro? (transpiler-std-macro-expander tr) x)
                             (expander-has-macro? (transpiler-codegen-expander tr) x)))
(transpiler-getter imported-variable? (& (transpiler-import-from-environment? tr)
                                         (transpiler-host-variable? tr x)))

(defun transpiler-add-defined-function (tr name args body)
  (= (href (transpiler-defined-functions-hash tr) name) t)
  (transpiler-add-function-args tr name args)
  (transpiler-add-function-body tr name body)
  name)

(defun transpiler-add-function-args (tr fun args) (= (href (transpiler-function-args tr) fun) args))
(defun transpiler-add-function-body (tr fun args) (= (href (transpiler-function-bodies tr) fun) args))
(define-slot-setter-push transpiler-add-exported-closure tr  (transpiler-exported-closures tr))
(define-slot-setter-push transpiler-add-plain-arg-fun tr     (transpiler-plain-arg-funs tr))
(define-slot-setter-push transpiler-add-emitted-decl tr      (transpiler-emitted-decls tr))
(defun transpiler-add-delayed-var-init (tr x)    (nconc! (transpiler-delayed-var-inits tr) (copy-tree (transpiler-frontend tr x))))

(defun transpiler-add-plain-arg-funs (tr lst)
  (adolist lst
    (transpiler-add-plain-arg-fun tr !)))

(defun transpiler-add-obfuscation-exceptions (tr &rest x)
  (adolist x
	(= (href (transpiler-obfuscations tr) (make-symbol (symbol-name !)))
	   t)))

(defun transpiler-add-late-symbol (tr x)
  (= (href (transpiler-late-symbols tr) x) t)
  x)

(defun transpiler-macro (tr name)
  (let expander (expander-get (transpiler-codegen-expander tr))
    (funcall (expander-lookup expander) expander name)))

(defun make-global-funinfo (tr)
  (= (transpiler-global-funinfo tr) (create-funinfo :name 'global-scope :parent nil :args nil :body nil :transpiler tr)))

(defun transpiler-package-symbol (tr x)
  (make-symbol (symbol-name x) (transpiler-current-package tr)))

(defun transpiler-add-functional (tr x)
  (= (href (transpiler-functionals-hash tr) x) t))

(defun transpiler-functional? (tr x)
  (href (transpiler-functionals-hash tr) x))

(defun transpiler-defined-symbol? (fi x)
  (let tr *transpiler*
    (| (funinfo-var-or-lexical? fi x)
       (function? x)
       (keyword? x)
       (member x (transpiler-predefined-symbols tr) :test #'eq)
       (in? x nil t '~%ret 'this)
       (transpiler-imported-variable? tr x)
       (transpiler-defined-function tr x)
       (transpiler-defined-variable tr x)
       (transpiler-macro? tr x)
       (transpiler-host-variable? tr x)
       (transpiler-late-symbol? tr x)
       (funinfo-var? (transpiler-global-funinfo tr) x))))

(defun current-transpiler-function-arguments (x)
  (alet *transpiler*
    (| (transpiler-function-arguments ! x)
       (transpiler-host-function-arguments ! x)
       (function-arguments (symbol-function x)))))

(defun transpiler-add-toplevel-expression (tr x)
  (push (copy-tree x) (transpiler-accumulated-toplevel-expressions tr)))

(defun transpiler-add-used-function (tr x)
  (= (href (transpiler-used-functions tr) x) t)
  x)
