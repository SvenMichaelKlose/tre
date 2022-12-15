(fn add-onload fun
  (!= (| onload #'(()))
    (= onload [(funcall !)
               (funcall fun)])))
