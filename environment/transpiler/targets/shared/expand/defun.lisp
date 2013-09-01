;;;;; tré – Copyright (c) 2008–2013 Sven Michael Klose <pixel@copei.de>

(defvar *allow-redefinitions?* nil)

(defun redef-warn (&rest args)
  (apply (? *allow-redefinitions?* #'warn #'error) args))

(defun apply-current-package (x)
  (!? (transpiler-current-package *transpiler*)
      (make-symbol (symbol-name x) !)
      x))

(defun shared-defun-profiling-body (tr name body)
  (? (& (transpiler-profile? tr)
        (not (eq 'add-profile name)
             (eq 'add-profile-call name)))
     (? (transpiler-profile-num-calls? tr)
        `((progn
            (& (not *profile-lock*)
               (add-profile-call ',name))
            ,@body))
        `((let ~%profiling-timer (& (not *profile-lock*) (%%%nanotime))
            (prog1
              (progn
                ,@body)
              (& ~%profiling-timer
                 (add-profile ',name (integer- (%%%nanotime) ~%profiling-timer)))))))
     body))

(defun shared-defun-memorize-source (tr name args body)
  (acons! name (cons args body) (transpiler-memorized-sources tr))
  nil)

(defun shared-defun-source-memorizer (tr name args body)
  (+ (& *have-compiler?*
        (not (transpiler-memorize-sources? tr))
        `((%setq *defined-functions* (cons ',name *defined-functions*))))
     (when (transpiler-save-sources? tr)
       (apply #'transpiler-add-obfuscation-exceptions tr (collect-symbols (list name args body)))
       (? (transpiler-memorize-sources? tr)
          (shared-defun-memorize-source tr name args body)
          `((%setq (slot-value ,name '__source) ,(let source (assoc-value name *function-sources* :test #'eq)
                                                   `'(,(| source. args) . ,(unless (transpiler-save-argument-defs-only? tr)
                                                                             (| .source body))))))))))

(defun shared-defun-backtrace (tr name body)
  (? (transpiler-backtrace? tr)
     `((push ',name *backtrace*)
       (prog1
         (progn
           ,@body)
         (= *backtrace* .*backtrace*)))
     body))

(defun shared-defun-without-expander (name args body &key (make-source-memorizer? nil))
  (= name (apply-current-package name))
  (print-definition `(defun ,name ,args))
  (| (list? args)
     (error "Argument list expected instead of ~A." args))
  (let tr *transpiler*
    (& (transpiler-defined-function tr name)
       (redef-warn "Redefinition of function ~A." name))
	(transpiler-add-defined-function tr name args body)
	`((function ,name (,args
                       ,@(& (body-has-noargs-tag? body)
                            '(no-args))
                       (block ,name
                         ,@(shared-defun-backtrace tr name (shared-defun-profiling-body tr name body)))))
      ,@(& make-source-memorizer?
           (shared-defun-source-memorizer tr name args body)))))

(defun shared-defun (name args body &key (make-expander? t))
  (let fun-name (%defun-name name)
    `(%%block
       ,@(shared-defun-without-expander fun-name args body :make-source-memorizer? t)
       ,@(when (& args make-expander?
                  (not (simple-argument-list? args)
                       (transpiler-assert? *transpiler*)))
           (with-gensym p
             (shared-defun-without-expander (c-expander-name fun-name) (list p)
                                            (list (compile-argument-expansion-function-body fun-name args p nil
                                                                                            (argument-expand-names 'compile-argument-expansion args)))
                                            :make-source-memorizer? nil))))))
