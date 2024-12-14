(fn getenv (x)
  (? (defined? process)
     (%aref process.env x)))
