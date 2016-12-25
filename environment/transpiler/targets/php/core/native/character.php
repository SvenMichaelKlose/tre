class __character {
    var $v;

	public function __construct ($num)
	{
		$this->v = $num;
        return $this;
	}

	public function __toString ()
	{
        return "#\\" . chr ($this->v) . " ";
	}
}
