(deftest "NOT 0 is NIL"
  ((not 0))
  nil)

(deftest "LENGHT with conses"
  ((length '(1 2 3 4)))
  (integer 4))

(deftest "LENGHT with strings"
  ((length "test"))
  (integer 4))
