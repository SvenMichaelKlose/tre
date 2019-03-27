(%%native "" "require_once 'db-config.php';")
(session-create)

(fn server-apply (fun-name &rest args)
  (apply (symbol-function fun-name) args))

(serve-http-funcall)
