$LEXICALS = Array ();
$LEXICALID = 0;

class __l {
    var $id;

	public function __construct ()
	{
		$this->id = ++$GLOBALS['LEXICALID'];
		$GLOBALS['LEXICALS'][$this->id] = Array ();
        return $this;
	}

    public function g ($i)
    {
		return $GLOBALS['LEXICALS'][$this->id][$i];
    }

    public function s ($i, $v)
    {
		$GLOBALS['LEXICALS'][$this->id][$i] = $v;
        return $v;
    }

    public function __toString ()
    {
        return "lexical scope context";
    }
}
