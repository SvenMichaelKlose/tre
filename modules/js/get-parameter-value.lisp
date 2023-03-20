; TODO: Use new 'Location' object.

(fn get-parameter-value (x)
  (with (url      window.location.href
         name     (x.replace "/[\[\]]/g" "\\$&")
         regex    (new *reg-exp (+ "[?&]" name "(=([^&#]*)|&|#|$)"))
         results  (regex.exec url))
    (when results
      (!? (aref results 2)
          (decode-u-r-i-component (!.replace "/\+/g" " "))
          ""))))
