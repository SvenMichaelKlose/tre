/*
 * tré – Copyright (c) 2005–2009,2012–2014 Sven Michael Klose <pixel@copei.de>
 */

treptr
cdrlist (treptr x)
{
    treptr  q = tre_make_queue ();
    treptr  i;

    tregc_push (q);
    DOLIST(i, x)
        tre_enqueue (q, CDAR(i));
    tregc_pop ();

    return tre_queue_list (q);
}

treptr
mapcar_carlist (treptr x)
{
    treptr  q = tre_make_queue ();
    treptr  i;

    tregc_push (q);
    DOLIST(i, x) {
        if (NOT(CAR(i)))
            goto skip_rest;
        ASSERT_CONS(CAR(i));
        tre_enqueue (q, CAAR(i));
    }
    tregc_pop ();

    return tre_queue_list (q);

skip_rest:
    tregc_pop ();
    return NIL;
}

treptr
mapcar (treptr fun, treptr x)
{
    treptr  q = tre_make_queue ();
    treptr  args;

    ASSERT_LIST(x);
    tregc_push (q);
    while (1) {
        tregc_push (x);
        args = mapcar_carlist (x);
        tregc_push (args);
        if (NOT(args))
            break;
        tre_enqueue (q, funcall (fun, args));
        x = cdrlist (x);
        tregc_pop ();
        tregc_pop ();
    }
    tregc_pop ();
    tregc_pop ();
    tregc_pop ();

    return tre_queue_list (q);
}
