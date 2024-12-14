(defbuiltin filter (fun x)
  (CL:MAPCAR fun x))

(defbuiltin mapcan (fun x)
  (CL:MAPCAN fun x))

(defbuiltin append (&rest x)
  (*> #'CL:NCONC (CL:MAPCAR #'CL:COPY-LIST x)))
