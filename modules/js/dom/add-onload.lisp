(fn add-onload fun
  (!= (| onload #'(()))
    (= onload [(~> !)
               (~> fun)])))
