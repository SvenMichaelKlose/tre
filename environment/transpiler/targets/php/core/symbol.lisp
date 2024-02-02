(defnative symbol (name pkg)
  (unless (%== "NIL" name)
    (| (%== "T" name)
       (new __symbol name pkg))))

(defnative =-symbol-function (v x)
  (x.sf v))

(defnative package-name (x))
