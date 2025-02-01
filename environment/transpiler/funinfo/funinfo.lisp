(var *funinfo*) ; Updated when walking LAMBDAs.

(def-gensym funinfo-sym ~f)

; Function information
; A global FUNINFO encompasses all the input code.
(defstruct funinfo
  (transpiler   nil)
  (parent       nil)

  ; Name of the function.
  ; Required past LAMBDA-EXPAND.
  (name         nil)

  (argdef       nil) ; Argument definition.
  (args         nil) ; Expanded argument definition.

  ; Variables of the function.
  (vars         nil) ; To keep the order.
  (vars-hash    nil) ; To speed things up.  The top-level FUNINFO
                     ; can become rather huge.

  ; Variables that are actually being used.  For warnings.
  (used-vars    nil)

  ; Variables used which haven't been defined.  E.g. native target
  ; variables.
  (free-vars    nil)

  ; Variables that are being modified.
  (places       nil)

  ; Variables that are passed on to closures inside the function.
  ; Effectively layouting the environment vector passed to
  ; closures by shadow env argument.
  (scoped-vars  nil)

  ; Local variable containing the environment vector for closures
  ; inside this function.
  (scope        nil)

  ; If this is a closure, this is the name of the shadow env argument.
  (scope-arg    nil)

  ; Name of hidden argument with an array of scoped-vars.
  (local-function-args nil)

  ; Tells if the env vector is modified.
  (fast-scope?  nil)

  (types        nil)  ; Strings of native type declarations.

  ; Number of jump tags in body.
  (num-tags     0)
  
  ; Global variables used by the function.  Used by the PHP target
  ; to generate 'global' statements.
  (globals      nil))

(fn funinfo-framesize (fi)
  (!= (funinfo-transpiler fi)
    (& (transpiler-stack-locals? !)
       (+ (length (funinfo-vars fi))
          (? (transpiler-arguments-on-stack? !)
             (length (funinfo-args fi))
             0)))))

(fn funinfo-toplevel? (fi)
  (!? (funinfo-parent fi)
      (not (funinfo-parent !))))

(def-funinfo copy-funinfo (fi)
  (make-funinfo
      :parent       parent
      :name         name
      :argdef       argdef
      :args         (copy-list args)
      :vars         (copy-list vars)
      :vars-hash    (copy-hash-table vars-hash)
      :used-vars    (copy-list used-vars)
      :free-vars    (copy-list free-vars)
      :places       (copy-list places)
      :scoped-vars  (copy-list scoped-vars)
      :scope        scope
      :scope-arg    scope-arg
      :local-function-args (copy-list local-function-args)
      :fast-scope?  fast-scope?
      :num-tags     num-tags
      :globals      (copy-list globals)))

(fn get-funinfo (name &optional (tr *transpiler*))
  "Get FUNINFO by name."
  (& name (href (transpiler-funinfos tr) name)))

(fn lambda-funinfo (x)
  "Get FUNINFO of named LAMBDA expression."
  (when (named-lambda? x)
    (get-funinfo (lambda-name x))))

(defmacro with-lambda-funinfo (x &body body)
  `(with-temporary *funinfo* (lambda-funinfo ,x)
     ,@body))

(fn create-funinfo (&key name parent args (transpiler *transpiler*))
  (& (href (transpiler-funinfos transpiler) name)
     (error "FUNFINFO for ~A is already memorized." name))
  (with (argnames  (argument-expand-names name args)
         fi        (make-funinfo :name          name
                                 :argdef        args
                                 :args          argnames
                                 :parent        parent
                                 :transpiler    transpiler))
    (= (href (transpiler-funinfos transpiler) name) fi)
    (funinfo-add-var fi *return-symbol*)
    (& (transpiler-copy-arguments-to-stack? transpiler)
       (@ [funinfo-add-var fi _] argnames))
    fi))

(fn funinfo-closure-without-free-vars? (fi)
  (& (funinfo-scope-arg fi)
     (not (funinfo-free-vars fi))))
