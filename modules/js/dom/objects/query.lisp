(fn $? (css-selector &optional (elm document))
  ((dom-extend elm).$? css-selector))

(fn $* (css-selector &optional (elm document))
  ((dom-extend elm).$* css-selector))
