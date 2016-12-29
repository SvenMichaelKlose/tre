(defbuiltin filter (fun x)
  (cl:mapcar fun x))

(defbuiltin append (&rest x)
  (apply #'cl:nconc (cl:mapcar #'cl:copy-list x)))
