(fn round (x &key (decimals 0))
  ((%%native round) x decimals))

(fn floor (x &key (decimals 0))
  ((%%native round) x decimals (%%native "PHP_ROUND_HALF_DOWN")))

(fn ceiling (x &key (decimals 0))
  ((%%native round) x decimals (%%native "PHP_ROUND_HALF_UP")))
