(%%native "" "require_once 'db-config.php';")

(princ (lml2xml `(html
                   (head
                     (title "tré PHP project"))
                   (body
                     "Hello world!"))))
