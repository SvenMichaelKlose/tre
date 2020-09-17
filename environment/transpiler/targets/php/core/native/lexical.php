$LEXICALS = Array ();
$LEXICALID = 0;

class __l {
    var $id;

	function __construct ()
	{
		$this->id = ++$GLOBALS['LEXICALID'];
		$GLOBALS['LEXICALS'][$this->id] = Array ();
        return $this;
	}

    function g ($i)
    {
		return $GLOBALS['LEXICALS'][$this->id][$i];
    }

    function s ($i, $v)
    {
		$GLOBALS['LEXICALS'][$this->id][$i] = $v;
        return $v;
    }

    function __toString ()
    {
        return "lexical scope context";
    }
}
