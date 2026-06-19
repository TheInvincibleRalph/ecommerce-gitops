<?php

require_once dirname(__DIR__, 2) . '/config/constants.php';

class Database
{
	private $con;

	public function connect(){
		$this->con = new Mysqli(HOST, USER, PASSWORD, DATABASE_NAME);
		return $this->con;
	}
}

?>
