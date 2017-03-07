(fn properties-alist (x)
  (@ [. _ (aref x _)] (property-names x)))

(fn alist-properties (x)
  (& x
     (aprog1 (new)
       (@ [= (aref ! _.) ._] x))))
