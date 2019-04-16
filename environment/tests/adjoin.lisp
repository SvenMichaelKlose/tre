(deftest "ADJOIN doesn't add known member"
  ((adjoin 'i '(l i s p)))
  '(l i s p))

(deftest "ADJOIN adds new member"
  ((adjoin 'a '(l i s p)))
  '(a l i s p))
