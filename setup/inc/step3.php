<?php
// $Id$

$config['debug_mode'] = 0;
$config['show_exec_time'] = 0;

$error = 0;
if (isset($_POST['username'])) { $username = htmlspecialchars($_POST['username']); }
if (isset($_POST['password'])) { $password = htmlspecialchars($_POST['password']); }

echo "<pre>Logging in... ";
if (isset($username) && isset($password)) {
	$result = $setup->denora->login($username, $password);
	if ($result[0]['uname'] == $username) {
		echo "<span style=\"color:green;\">Done</span></pre>";
		
		echo "<pre>Checking configuration table... ";
		$check = $setup->configCheck();
		if (!$check) { // Dump file to db
			echo " Creating... ";
			$result = $setup->configDump();
			$base_url = explode('setup/', $_SERVER['HTTP_REFERER']);
			$query = sprintf("UPDATE `magirc_config` SET `value` = '%s' WHERE `parameter` = 'base_url'", $base_url[0]);
			$setup->db->query($query, SQL_NONE);
			if ($result == 0) {
				echo "<span style=\"color:green;\">Done</span></pre>";
			} else {
				echo "<span style=\"color:red;\">Failed</span></pre>";
				$error = 1;
			}
		} else {
			echo "<span style=\"color:green;\">OK</span> (version ".$setup->getDbVersion().")</pre>";
		}
	} else {
		echo "<span style=\"color:red;\">Failed</span></pre>";
		$error = 1;
		echo "Please use a valid admin username and password, as specified in the denora server configuration file.";
	}
} else {
	$error = 1;
	echo "<span style=\"color:red;\">Failed</span></pre>";
}
if (!$error) {
	echo "<p>Setup finished! You <strong>MUST</strong> now logon into the <a href=\"../admin/\"><strong>Admin Interface</strong></a> to configure Magirc</p>";
}