;;;;; TRE transpiler
;;;;; Copyright (c) 2010 Sven Klose <pixel@copei.de>

(defstruct cblock
  (code nil)
  (next nil)
  (conditional-next nil)
  (conditional-place nil)
  (ins nil)
  (outs nil)
  (merged-ins nil))
