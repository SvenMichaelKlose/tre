(fn shared-defun-source (body)
  (with-string-stream s
    (with-temporaries (*print-automatic-newline?*
                         nil
                       *invisible-package-names*
                         (. "COMMON-LISP" *invisible-package-names*))
      (late-print body s))))

(fn shared-defun-source-setter (name args body)
  `((%= (slot-value ,name '__source)
        (. ,(shared-defun-source args)
           ,(unless (configuration :keep-argdef-only?)
              (shared-defun-source body))))))

(fn shared-defun-without-expander (name args body &key (keep-source? nil))
  (print-definition `(fn ,name ,args))
  (let body-in-blocks `((block ,name
                           (block nil
                             ,@(remove 'no-args body))))
    (add-defined-function name args body-in-blocks)
    `((function ,name (,args
                       ,@(& (eq 'no-args body.)
                            '(no-args))
                       ,@body-in-blocks))
      ,@(when (& keep-source? (configuration :keep-source?))
          (!= (remove 'no-args body)
            (? (configuration :keep-source?)
               (progn
                 (acons! name (. args !) (original-sources))
                 nil)
               (shared-defun-source-setter name args !)))))))

(fn fn? (x)
  (& (cons? x)
     (in? x. 'fn 'defun)))

(fn compile-nested-fns (body)
  (!? (remove-if-not #'fn? body)
      `((with ,(+@ [`(,._. #',.._)] !)
         ,@(remove-if #'fn? body)))
      body))

(fn shared-defun (name args body
                  &key (make-expander? t)
                       (keep-source?   t))
  (= name (%fn-name name))
  (= args (& args (ensure-list args)))
  (= body (compile-nested-fns body))
  `(progn
     ,@(shared-defun-without-expander name args body
                                      :keep-source? keep-source?)
     ,@(& make-expander?
          (| (always-expand-arguments?)
             (not (simple-argument-list? args)))
          (with-gensym expander-arg
            (shared-defun-without-expander
                (c-expander-name name)
                (… expander-arg)
                (make-argument-expander-function-body name args expander-arg))))))
