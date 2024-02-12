(fn count-tags-fun (x)
  (!= (lambda-body x)
    (= (funinfo-num-tags (lambda-funinfo x)) (count-if #'number? !))
    (count-tags !)))

(metacode-walker count-tags (x)
  :if-named-function
    (count-tags-fun x.))
