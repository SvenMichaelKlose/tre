(var *funinfo*)

(define-gensym-generator funinfo-sym ~f)

(defstruct funinfo
  (transpiler   nil)
  (parent       nil)
  (name         nil)

  (argdef       nil) ; Argument definition.
  (args         nil) ; Expanded argument definition.

  (vars         nil)
  (vars-hash    nil)
  (used-vars    nil)
  (free-vars    nil)
  (places       nil)

  (scoped-vars  nil) ; List of symbols exported to child functions.
  (scope        nil) ; Name of the array of scoped-vars.
  (scope-arg    nil) ; Name of hidden argument with an array of scoped-vars.
  (local-function-args nil)
  (fast-scope?  nil)

  (types        nil)  ; Strings of native type declarations.

  ; Number of jump tags in body.
  (num-tags     nil)
  
  (globals      nil))

(fn funinfo-framesize (fi)
  (!= (funinfo-transpiler fi)
    (& (transpiler-stack-locals? !)
       (+ (length (funinfo-vars fi))
          (? (transpiler-arguments-on-stack? !)
             (length (funinfo-args fi))
             0)))))

(fn funinfo-topmost (fi)
  (awhen (funinfo-parent fi)
    (? (& !
          (not (funinfo-parent !)))
       fi
       (funinfo-topmost !))))

(fn funinfo-toplevel? (fi)
  (!? (funinfo-parent fi)
      (not (funinfo-parent !))))

(def-funinfo copy-funinfo (funinfo)
  (make-funinfo
      :parent       parent
      :name         name
      :argdef        argdef
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
  (& name (href (transpiler-funinfos tr) name)))

(fn get-lambda-funinfo (x)
  (when (named-lambda? x)
    (get-funinfo (lambda-name x))))

(defmacro with-global-funinfo (&body body)
  `(with-temporary *funinfo* (global-funinfo)
     ,@body))

(defmacro with-lambda-funinfo (x &body body)
  `(with-temporary *funinfo* (get-lambda-funinfo ,x)
     ,@body))

(fn create-funinfo (&key name parent args (transpiler *transpiler*))
  (& (href (transpiler-funinfos transpiler) name)
     (error "FUNFINFO for ~A is already memorized." name))
  (with (argnames (argument-expand-names 'lambda-expand args)
         fi       (make-funinfo :name          name
                                :argdef        args
                                :args          argnames
                                :parent        parent
                                :transpiler    transpiler))
    (= (href (transpiler-funinfos transpiler) name) fi)
    (funinfo-var-add fi '~%ret)
    (& (transpiler-copy-arguments-to-stack? transpiler)
       (@ [funinfo-var-add fi _] argnames))
    fi))

(fn funinfo-closure-without-free-vars? (fi)
  (& (funinfo-scope-arg fi)
     (not (funinfo-free-vars fi))))
