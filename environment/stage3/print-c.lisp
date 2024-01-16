(fn %print-object (x str info))

(fn %print-get-args (args def)
  (argument-expand 'print def args :break-on-errors? nil))
