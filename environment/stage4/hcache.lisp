(fn hcache-remove (plc &rest vals)
  (& plc vals
     (| (not .vals)
        (~> #'hcache-remove plc .vals))
     (| (hremove plc vals.)
        t)))

(fn hcache (plc &rest vals)
  (& plc vals
     (| (& (not .vals)
           (href plc vals.))
        (~> #'hcache (href plc vals.) .vals))))

(fn %=-hcache (x plc vals)
  (? .vals
     (%=-hcache x (| (href plc vals.)
                     (= (href plc vals.) (make-hash-table)))
                .vals)
     (= (href plc vals.) x)))

(fn (= hcache) (x plc &rest vals)
  (%=-hcache x plc vals))
