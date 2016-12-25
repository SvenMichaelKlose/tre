(defun collect-symbols (x)
  (with-queue q
    (with (f    [& _
                   (? (& (symbol? _)
                         (empty-string? (symbol-name _)))
                      (enqueue q _)
                      (when (cons? _)
                        (f _.)
                        (f ._)))])
      (f x)
      (queue-list q))))

(defvar *allow-redefinitions?* t)

(defun redef-warn (&rest args)
  (apply (? *allow-redefinitions?* #'warn #'error) args))

(defun apply-current-package (x)
  (!? (current-package)
      (make-symbol (symbol-name x) !)
      x))

(defun shared-defun-profiling-body (name body)
  (? (& (profile?)
        (not (eq 'add-profile name)
             (eq 'add-profile-call name)))
     (? (profile-num-calls?)
        `({(& (not *profile-lock*)
              (add-profile-call ',name))
           ,@body})
        `((let ~%profiling-timer (& (not *profile-lock*)
                                    (%%%nanotime))
            (prog1
              {,@body}
              (& ~%profiling-timer
                 (add-profile ',name (- (%%%nanotime) ~%profiling-timer)))))))
     body))

(defun shared-defun-memorize-source (name args body)
  (acons! name (. args body) (memorized-sources))
  nil)

(defun shared-defun-source (body)
  (with-string-stream s
    (with-temporaries (*print-automatic-newline?*  nil
                       *invisible-package-names*   (. "COMMON-LISP"
                                                      *invisible-package-names*))
      (late-print body s))))

(defun shared-defun-source-setter (name args body)
  `((%= (slot-value ,name '__source) (. ,(shared-defun-source args)
                                        ,(unless (configuration :save-argument-defs-only?)
                                           (shared-defun-source body))))))

(defun shared-defun-source-memorizer (name args body)
  (when (configuration :save-sources?)
    (apply #'add-obfuscation-exceptions (collect-symbols (list name args body)))
    (? (configuration :memorize-sources?)
       (shared-defun-memorize-source name args body)
       (shared-defun-source-setter name args body))))

(defun shared-defun-backtrace (name body)
  (? (& (backtrace?)
        (not (in? name '%cons '__cons)))
     `((setq nil (%backtrace-push ',name))
       (prog1 {,@body}
         (%backtrace-pop)))
     body))

(defun shared-defun-without-expander (name args body
                                      &key (allow-source-memorizer? nil)
                                           (allow-backtrace? nil))
  (= name (apply-current-package name))
  (print-definition `(defun ,name ,args))
  (let body-with-block `((block ,name
                           (block nil
                             ,@(list-without-noargs-tag body))))
    (| (list? args)
       (error "Argument list expected instead of ~A." args))
    (& (defined-function name)
       (redef-warn "Redefinition of function ~A." name))
    (add-defined-function name args body-with-block)
    `((function ,name (,args
                       ,@(& (body-has-noargs-tag? body)
                            '(no-args))
                       ,@(alet (shared-defun-profiling-body name body-with-block)
                           (? allow-backtrace?
                              (shared-defun-backtrace name !)
                              !))))
      ,@(& allow-source-memorizer?
           (shared-defun-source-memorizer name args (list-without-noargs-tag body))))))

(defun shared-defun (name args body &key (make-expander? t))
  (& (macro? name)
     (add-used-function name))
  (let fun-name (%defun-name name)
    `{,@(shared-defun-without-expander fun-name args body
                                       :allow-source-memorizer? t
                                       :allow-backtrace? t)
      ,@(when (& make-expander?
                 (| (always-expand-arguments?)
                    (not (simple-argument-list? args))))
          (with-gensym expander-arg
            (shared-defun-without-expander (c-expander-name fun-name)
                                           (list expander-arg)
                                           (compile-argument-expansion-function-body fun-name args expander-arg))))}))
