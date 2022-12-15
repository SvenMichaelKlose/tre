(fn $$ (x &key (parent nil))
  (lml2dom (lml-expand (lml-hook (lml-expand x))) :parent parent))
