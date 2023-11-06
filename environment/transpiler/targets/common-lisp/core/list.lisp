(defbuiltin filter (fun x)
  (CL:MAPCAR fun x))

(defbuiltin append (&rest x)
  (apply #'CL:NCONC (CL:MAPCAR #'CL:COPY-LIST x)))
