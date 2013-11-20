;;;;; tré – Copyright (c) 2009–2013 Sven Michael Klose <pixel@copei.de>

(define-element-getters :name tbody
                        :plural-name tbodies
                        :tag "tbody")

(define-element-getters :name table
                        :plural-name tables
                        :tag "table")

(define-element-getters :name th
                        :plural-name ths
                        :tag "th")

(define-element-getters :name tr
                        :plural-name trs
                        :tag "tr")

(define-element-getters :name td
                        :plural-name tds
                        :tag "td")

(defun table-get-rows (x)
  (get-first-tbody (ancestor-or-self-table x)).children-list)

(defun table-num-columns (x)
  (ancestor-or-self-tr x).children.length)

(defun table-num-rows (x)
  (ancestor-or-self-table x).children.length)

(defun table-get-first-row (x)
  (get-first-tbody (ancestor-or-self-table x)).first-child)

(defun table-get-column-index (cell)
  (cell.get-index))

(defun table-get-column-0 (x idx)
  (when x
	(cons (x.get-child-at idx)
		  (table-get-column-0 x.next-sibling idx))))

(defun table-get-column (x)
  (table-get-column-0 (table-get-first-row x) (table-get-column-index x)))

(defun table-insert-column-0 (index rows column after?)
  (when rows
    (((car rows).get-child-at index).insert-next-to column. after?)
    (table-insert-column-0 index .rows .column after?)))

(defun table-insert-column (drop-cell column after?)
  (assert (== (length (table-get-rows drop-cell))
		      (length column))
	  	  (error "column not the same"))
  (table-insert-column-0 (table-get-column-index drop-cell) (table-get-rows drop-cell) column after?))
