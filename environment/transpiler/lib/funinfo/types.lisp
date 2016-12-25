(defun funinfo-get-type (fi name)
  (cdr (assoc (funinfo-types fi) name)))

(defun funinfo-add-type (fi name x)
  (& (funinfo-get-type fi name)
     (error "Type already declared for ~A in ~A." name (funinfo-name fi)))
  (push (. name x) (funinfo-types fi)))
