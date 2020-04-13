$SYMBOLVALUES = Array ();
$SYMBOLFUNCTIONS = Array ();

class __symbol {
    var $n;
    var $p;

	function __construct ($name, $pkg)
	{
		$this->n = $name;
		$this->p = $pkg;
        $pn = $this->pn ();
        if (!isset ($GLOBALS['SYMBOLVALUES'][$pn])) {
            $GLOBALS['SYMBOLVALUES'][$pn] = Array ($name => $this);
            $GLOBALS['SYMBOLFUNCTIONS'][$pn] = Array ();
        }
        return $this;
	}

    function pn ()
    {
        return $this->p ? $this->p->n : "NIL";
    }

    function v ()
    {
        return $GLOBALS['SYMBOLVALUES'][$this->pn ()][$this->n];
    }

    function f ()
    {
        return $GLOBALS['SYMBOLFUNCTIONS'][$this->pn ()][$this->n];
    }

    function sv ($v)
    {
        return $GLOBALS['SYMBOLVALUES'][$this->pn ()][$this->n] = $v;
    }

    function sf ($v)
    {
        return $GLOBALS['SYMBOLFUNCTIONS'][$this->pn ()][$this->n] = $v;
    }

    function __toString ()
    {
        $pn = $this->pn ();
        return ($pn != "NIL" ? "$pn:" : "") . $this->n;
    }
}

$KEYWORDPACKAGE = new __symbol ("", NULL);
