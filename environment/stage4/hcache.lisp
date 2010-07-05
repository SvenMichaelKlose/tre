;;;;; TRE environment
;;;;; Copyright (c) 2010 Sven Klose <pixel@copei.de>

(defun %hcache-remove (plc vals)
  (and plc vals
  	   (and (or (not .vals)
	  	   		(%hcache-remove plc .vals))
			(or (hremove plc vals.)
			    t))))

(defun hcache-remove (plc &rest vals)
  (%hcache-remove plc vals))

(defun %hcache (plc vals)
  (and plc vals
  	   (or (and (not .vals)
		   	    (href plc vals.))
	  	   (%hcache (href plc vals.) .vals))))

(defun hcache (plc &rest vals)
  (%hcache plc vals))

(defun %setf-hcache (x plc vals)
  (if .vals
	  (%setf-hcache x (or (href plc vals.)
		   				  (setf (href plc vals.) (make-hash-table)))
					  .vals)
	  (setf (href plc vals.) x)))

(defun (setf hcache) (x plc &rest vals)
  (%setf-hcache x plc vals))
