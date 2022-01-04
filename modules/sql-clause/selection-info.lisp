(defstruct selection-info
  (fields    nil)
  table
  (where     nil)
  (offset    nil)
  (limit     nil)
  (order-by  nil)
  (direction nil))

(def-selection-info selection-info-add-where (selection-info x)
  (= (selection-info-where selection-info) (? where
                                              (+ where " AND " x)
                                              x))
  selection-info)
