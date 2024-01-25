(fn refine (fun x)
  "Refine X using FUN until no further changes occur."
  (!= (~> fun x)
    (? (equal x !)
       !
       (refine fun !))))
