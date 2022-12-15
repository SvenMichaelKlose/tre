(fn table-get-rows (x)
  (((x.get "<table").get "tbody").child-list))

(fn table-num-columns (x)
  ((x.get "<table").get "tr").children.length)

(fn table-num-rows (x)
  ((x.get "<table").get "tbody").children.length)

(fn table-get-first-row (x)
  ((x.get "<table").get "tbody").first-child)

(fn table-get-column-0 (x idx)
  (& x
     (. (x.get-child-at idx)
        (table-get-column-0 x.next-sibling idx))))

(fn table-get-column (x)
  (table-get-column-0 (table-get-first-row x) (x.get-index)))

(fn table-insert-column (drop-cell column after?)
  (assert (== (length (table-get-rows drop-cell))
              (length column))
          (error "column not the same"))
  (let index (drop-cell.get-index)
    (mapcar #'((row column-cell)
                ((row.get-child-at index).insert-next-to column-cell after?))
            (table-get-rows drop-cell)
            column)))
