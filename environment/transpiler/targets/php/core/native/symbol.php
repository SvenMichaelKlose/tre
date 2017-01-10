$SYMBOLVALUES = Array ();
$SYMBOLFUNCTIONS = Array ();

class __symbol {
    var $n;
    var $p;

	public function __construct ($name, $pkg)
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

    public function pn ()
    {
        return $this->p ? $this->p->n : "NIL";
    }

    public function v ()
    {
        return $GLOBALS['SYMBOLVALUES'][$this->pn ()][$this->n];
    }

    public function f ()
    {
        return $GLOBALS['SYMBOLFUNCTIONS'][$this->pn ()][$this->n];
    }

    public function sv ($v)
    {
        return $GLOBALS['SYMBOLVALUES'][$this->pn ()][$this->n] = $v;
    }

    public function sf ($v)
    {
        return $GLOBALS['SYMBOLFUNCTIONS'][$this->pn ()][$this->n] = $v;
    }

    public function __toString ()
    {
        return (($this->pn ()) ? ":" : "") . $this->n;
    }
}

$KEYWORDPACKAGE = new __symbol ("", NULL);
