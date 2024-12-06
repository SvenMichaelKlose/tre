(macro !aadjoin! (key init new-cdr al &key (test #'equal))
  `(!? (assoc key al :test ,test)
       new-cdr
       (acons! key init al)))
