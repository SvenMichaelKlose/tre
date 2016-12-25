(defun hcache-remove (plc &rest vals)
  (& plc vals
  	 (| (not .vals)
	 	(apply #'hcache-remove plc .vals))
	 (| (hremove plc vals.)
		t)))

(defun hcache (plc &rest vals)
  (& plc vals
     (| (& (not .vals)
		   (href plc vals.))
	  	(apply #'hcache (href plc vals.) .vals))))

(defun %=-hcache (x plc vals)
  (? .vals
     (%=-hcache x (| (href plc vals.)
	                 (= (href plc vals.) (make-hash-table)))
			    .vals)
     (= (href plc vals.) x)))

(defun (= hcache) (x plc &rest vals)
  (%=-hcache x plc vals))
