;;;;; tré – Copyright (c) 2008–2013 Sven Michael Klose <pixel@copei.de>

(defvar *allow-redefinitions?* nil)

(defun redef-warn (&rest args)
  (apply (? *allow-redefinitions?* #'warn #'error) args))

(defun apply-current-package (x)
  (!? (transpiler-current-package *transpiler*)
      (make-symbol (symbol-name x) !)
      x))

(defun shared-defun-profiling-body (name body)
  (alet *transpiler*
    (? (& (transpiler-profile? !)
          (not (eq 'add-profile name)
               (eq 'add-profile-call name)))
       (? (transpiler-profile-num-calls? !)
          `((progn
              (& (not *profile-lock*)
                 (add-profile-call ',name))
              ,@body))
          `((let ~%profiling-timer (& (not *profile-lock*)
                                      (%%%nanotime))
              (prog1
                (progn
                  ,@body)
                (& ~%profiling-timer
                   (add-profile ',name (integer- (%%%nanotime) ~%profiling-timer)))))))
       body)))

(defun shared-defun-memorize-source (name args body)
  (acons! name (cons args body) (transpiler-memorized-sources *transpiler*))
  nil)

(defun shared-defun-source-memorizer (name args body)
  (alet *transpiler*
    (+ (& *have-compiler?*
          (not (transpiler-memorize-sources? !))
          `((%setq *defined-functions* (cons ',name *defined-functions*))))
       (when (transpiler-save-sources? !)
         (apply #'transpiler-add-obfuscation-exceptions ! (collect-symbols (list name args body)))
         (? (transpiler-memorize-sources? !)
            (shared-defun-memorize-source name args body)
            `((%setq (slot-value ,name '__source) ,(let source (assoc-value name *function-sources* :test #'eq)
                                                     `'(,(| source. args) . ,(unless (transpiler-save-argument-defs-only? !)
                                                                               (| .source body)))))))))))

(defun shared-defun-backtrace (name body)
  (? (transpiler-backtrace? *transpiler*)
     `((push ',name *backtrace*)
       (prog1
         (progn
           ,@body)
         (= *backtrace* .*backtrace*)))
     body))

(defun shared-defun-without-expander (name args body &key (source-memorizer? nil) (allow-backtrace? nil))
  (= name (apply-current-package name))
  (print-definition `(defun ,name ,args))
  (| (list? args)
     (error "Argument list expected instead of ~A." args))
  (& (transpiler-defined-function *transpiler* name)
     (redef-warn "Redefinition of function ~A." name))
  (transpiler-add-defined-function *transpiler* name args body)
  `((function ,name (,args
                     ,@(& (body-has-noargs-tag? body)
                          '(no-args))
                     (block ,name
                       ,@(alet (shared-defun-profiling-body name body)
                           (? allow-backtrace?
                              (shared-defun-backtrace name !)
                              !)))))
      ,@(& source-memorizer?
           (shared-defun-source-memorizer name args body))))

(defun shared-defun (name args body &key (make-expander? t))
  (let fun-name (%defun-name name)
    `(%%block
       ,@(shared-defun-without-expander fun-name args body :source-memorizer? t :allow-backtrace? t)
       ,@(when (& make-expander?
                  (| (not (simple-argument-list? args))
                     (transpiler-assert? *transpiler*)))
           (with-gensym p
             (shared-defun-without-expander (c-expander-name fun-name) (list p)
                                            (compile-argument-expansion-function-body fun-name args p)
                                            :source-memorizer? nil))))))
