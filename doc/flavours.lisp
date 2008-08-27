### NON-STANDARD BEHAVIOURS #################################################

VARIABLES AND SYMBOLS

    Variables and symbols are basically the same. Symbols evaluate to
    themselves.

COMPUTATIONAL VALUES

    Number atoms are not looked up for computational values in favor of
    performance.

    * (eq 1 (+ 0 1))
    NIL

    (+ 0 1) will evaluate to a new number.

    Recursive functions will waste a lot of numbers.
