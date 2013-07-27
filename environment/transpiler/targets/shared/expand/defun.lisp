;;;;; tré – Copyright (c) 2008–2013 Sven Michael Klose <pixel@copei.de>

(defvar *allow-redefinitions?* nil)

(defun redef-warn (&rest args)
  (apply (? *allow-redefinitions?* #'warn #'error) args))

(defun apply-current-package (x)
  (!? (transpiler-current-package *transpiler*)
      (make-symbol (symbol-name x) !)
      x))

(defun shared-defun-funcall-logger (name)
  (& *log-functions?*
     (not (eq '%%%log name))
     `((& (function? raw-log) (%%%log ,(symbol-name name))))))

(defun shared-defun-profiling-body (tr name body)
  (alet (body-without-noargs-tag body)
    (? (& (transpiler-profile? tr)
          (not (eq 'add-profile name)
               (eq 'add-profile-call name)))
       (? (transpiler-profile-num-calls? tr)
          `((progn
              (& (not *profile-lock*)
                 (add-profile-call ',name))
              ,@!))
          `((let ~%profiling-timer (& (not *profile-lock*) (%%%nanotime))
              (prog1
                (progn ,@!)
                  (& ~%profiling-timer
                     (add-profile ',name (integer- (%%%nanotime) ~%profiling-timer)))))))
       !)))

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

(defun shared-defun (name args &rest body)
  (= name (apply-current-package name))
  (print-definition `(defun ,name ,args))
  (| (list? args)
     (error "Argument list expected instead of ~A." args))
  (let tr *transpiler*
    (& (transpiler-defined-function tr name)
       (redef-warn "Redefinition of function ~A." name))
	(transpiler-add-defined-function tr name args body)
	`(%%block
       (function ,name (,args
                        ,@(& (body-has-noargs-tag? body) '(no-args))
                        (block ,name
                          ,@(shared-defun-backtrace tr name (+ (shared-defun-funcall-logger name)
                                                               (shared-defun-profiling-body tr name body))))))
       ,@(shared-defun-source-memorizer tr name args body))))
