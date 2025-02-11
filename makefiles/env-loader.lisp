(cl:in-package :tre)
(cl:format t "; Loading environment…~%")
(cl:setq *package* "TRE")

(cl:defun %env-path ()
  (cl:or ;(cl:if (cl:fboundp 'ql:where-is-system)
         ;       (ql:where-is-system :tre))
         ;(cl:if (cl:fboundp 'asdf:system-source-directory)
         ;       (asdf:system-source-directory :tre))
         (cl:if cl:*load-truename*
                (cl:make-pathname :defaults cl:*load-truename* :name nil :type nil))
         cl:*default-pathname-defaults*))
(uiop:chdir (%env-path))
(cl:defparameter *environment-path* (cl:namestring (%env-path)))

(env-load "main.lisp")
