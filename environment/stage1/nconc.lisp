(defun %nconc-0 (lsts)
  (when lsts
    (!? lsts.
	    {(rplacd (last !) (%nconc-0 .lsts))
		 !}
		(%nconc-0 .lsts))))

(defun nconc (&rest lsts)
  (%nconc-0 lsts))
