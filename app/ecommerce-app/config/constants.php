<?php

define('HOST', getenv('DB_HOST') ?: 'localhost');
define('USER', getenv('DB_USERNAME') ?: 'root');
define('PASSWORD', getenv('DB_PASSWORD') ?: '');
define('DATABASE_NAME', getenv('DB_DATABASE') ?: 'ecommerceapp');

define('CURRENCY', 'Rs');

?>
