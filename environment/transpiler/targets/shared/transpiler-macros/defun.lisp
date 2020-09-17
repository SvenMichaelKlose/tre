(fn shared-defun-memorize-source (name args body)
  (acons! name (. args body) (memorized-sources))
  nil)

(fn shared-defun-source (body)
  (with-string-stream s
    (with-temporaries (*print-automatic-newline?*  nil
                       *invisible-package-names*   (. "COMMON-LISP"
                                                      *invisible-package-names*))
      (late-print body s))))

(fn shared-defun-source-setter (name args body)
  `((%= (slot-value ,name '__source) (. ,(shared-defun-source args)
                                        ,(unless (configuration :save-argument-defs-only?)
                                           (shared-defun-source body))))))

(fn shared-defun-source-memorizer (name args body)
  (when (configuration :save-sources?)
    (? (configuration :memorize-sources?)
       (shared-defun-memorize-source name args body)
       (shared-defun-source-setter name args body))))

(fn shared-defun-backtrace (name body)
  (? (& (backtrace?)
        (not (in? name '%cons '__cons)))
     `((setq nil (%backtrace-push ',name))
       (prog1 (progn
                ,@body)
         (%backtrace-pop)))
     body))

(fn shared-defun-without-expander (name args body &key (allow-source-memorizer? nil)
                                                       (allow-backtrace? nil))
  (print-definition `(fn ,name ,args))
  (let body-with-block `((block ,name
                           (block nil
                             ,@(remove 'no-args body))))
    (| (list? args)
       (error "Argument list expected instead of ~A." args))
    (& (defined-function name)
       (warn "Redefining #'~A." name))

    (add-defined-function name args body-with-block)
    `((function ,name (,args
                       ,@(& (eq 'no-args body.)
                            '(no-args))
                       ,@(!= body-with-block
                           (? allow-backtrace?
                              (shared-defun-backtrace name !)
                              !))))
      ,@(& allow-source-memorizer?
           (shared-defun-source-memorizer name args (remove 'no-args body))))))

(fn shared-defun (name args body &key (make-expander? t) (allow-source-memorizer? t))
  (let fun-name (%fn-name name)
    `(progn
       ,@(shared-defun-without-expander fun-name args body
                                        :allow-source-memorizer? allow-source-memorizer?
                                        :allow-backtrace? t)
       ,@(& make-expander?
            (| (always-expand-arguments?)
               (not (simple-argument-list? args)))
            (with-gensym expander-arg
              (shared-defun-without-expander (c-expander-name fun-name)
                                             (list expander-arg)
                                             (compile-argument-expansion-function-body fun-name args expander-arg)))))))
