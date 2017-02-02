(fn search (needle haystack &key (test #'eql))
  (& haystack
     (not (zero? (length haystack)))
     (| (& (funcall test needle (subseq haystack 0 (length needle)))
           haystack)
        (search needle (subseq haystack 1) :test test))))
