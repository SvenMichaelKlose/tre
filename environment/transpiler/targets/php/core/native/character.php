class __character {
    var $v;

	function __construct ($num)
	{
		$this->v = $num;
        return $this;
	}

	function __toString ()
	{
        return "#\\" . chr ($this->v) . " ";
	}
}
