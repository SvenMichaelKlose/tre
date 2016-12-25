(defvar *default-listprop* nil)

(defbuiltin cpr (x) x nil)
(defbuiltin rplacp (v x) x v)

(defbuiltin filter (fun x) (cl:mapcar fun x))
(defbuiltin append (&rest x) x (apply #'cl:nconc (cl:mapcar #'cl:copy-list x)))
