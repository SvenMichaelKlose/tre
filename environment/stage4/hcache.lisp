;;;;; tré – Copyright (c) 2010,2012 Sven Michael Klose <pixel@copei.de>

(defun %hcache-remove (plc vals)
  (& plc vals
  	 (| (not .vals)
	 	(%hcache-remove plc .vals))
	 (| (hremove plc vals.)
		t)))

(defun hcache-remove (plc &rest vals)
  (%hcache-remove plc vals))

(defun %hcache (plc vals)
  (& plc vals
     (| (& (not .vals)
		   (href plc vals.))
	  	(%hcache (href plc vals.) .vals))))

(defun hcache (plc &rest vals)
  (%hcache plc vals))

(defun %=-hcache (x plc vals)
  (? .vals
     (%=-hcache x (| (href plc vals.)
	                 (= (href plc vals.) (make-hash-table)))
			    .vals)
     (= (href plc vals.) x)))

(defun (= hcache) (x plc &rest vals)
  (%=-hcache x plc vals))
