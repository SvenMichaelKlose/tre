(fn schema-type (x)
  (? (string? x)
     x
     x.type))
