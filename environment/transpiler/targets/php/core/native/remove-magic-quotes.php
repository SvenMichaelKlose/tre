# From somewhere in the official PHP documentation comments.
if (get_magic_quotes_gpc ()) {
    $vars = array (&$_GET, &$_POST, &$_COOKIE, &$_REQUEST);
    while (list ($key, $val) = each ($vars)) {
        foreach ($val as $k => $v) {
            unset ($vars[$key][$k]);
            $sk = stripslashes ($k);
            if (is_array ($v)) {
                $vars[$key][$sk] = $v;
                $vars[] = &$vars[$key][$sk];
            } else
                $vars[$key][$sk] = stripslashes ($v);
        }
    }
    unset ($vars);
}
