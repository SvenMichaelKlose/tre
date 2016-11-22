; tré – Copyright (c) 2009–2013,2015–2016 Sven Michael Klose <pixel@copei.de>

(defun table-get-rows (x)
  (((x.get "<table").get "tbody").child-list))

(defun table-num-columns (x)
  ((x.get "<table").get "tr").children.length)

(defun table-num-rows (x)
  (x.get "<table").children.length)

(defun table-get-first-row (x)
  ((x.get "<table").get "tbody").first-child)

(defun table-get-column-0 (x idx)
  (& x
	 (. (x.get-child-at idx)
        (table-get-column-0 x.next-sibling idx))))

(defun table-get-column (x)
  (table-get-column-0 (table-get-first-row x) (x.get-index)))

(defun table-insert-column (drop-cell column after?)
  (assert (== (length (table-get-rows drop-cell))
		      (length column))
	  	  (error "column not the same"))
  (let index (drop-cell.get-index)
    (mapcar #'((row column-cell)
                ((row.get-child-at index).insert-next-to column-cell after?))
            (table-get-rows drop-cell)
            column)))
