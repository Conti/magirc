<?php
// Root path
define('PATH_ROOT', __DIR__ . '/../../');

// Database configuration
class Magirc_DB extends DB {
	function __construct() {
		parent::__construct();
		$error = false;
		if (file_exists(PATH_ROOT.'conf/magirc.cfg.php')) {
			include(PATH_ROOT.'conf/magirc.cfg.php');
		} else {
			$error = true;
		}
		if (!isset($db)) {
			$error = true;
		}
		if ($error) {
			die ('<strong>MagIRC</strong> is not configured<br />Please run <a href="setup/">Setup</a>');
		}
		$dsn = "mysql:dbname={$db['database']};host={$db['hostname']}";
		$this->connect($dsn, $db['username'], $db['password']) || die('Error opening Magirc database<br />'.$this->error);
	}
}

class Magirc {
	public $db;
	public $cfg;
	public $tpl;
	public $slim;
	public $denora;

	/**
	 * Magirc Class Constructor
	 * @param type $api_mode ('web': frontend, 'denora': Denora API)
	 */
	function __construct($api_mode = "web") {
		// Setup the Slim framework
		$this->slim = new Slim();
		if ($api_mode == "web") {
			// Setup the template engine
			$this->tpl = new Smarty;
			$this->tpl->template_dir = 'theme/default/tpl';
			$this->tpl->config_dir = 'theme/default/cfg';
			$this->tpl->compile_dir = 'tmp';
			$this->tpl->cache_dir = 'tmp';
			$this->tpl->autoload_filters = array('pre' => array('jsmin'));
			$this->tpl->addPluginsDir('lib/smarty-plugins/');
		}

		// Setup the database
		$this->db = new Magirc_DB;
		$query = "SHOW TABLES LIKE 'magirc_config'";
		$this->db->query($query, SQL_INIT);
		if (!$this->db->record) {
			$this->displayError('Database table missing. Please run setup.', $api_mode);
		}

		// Get the configuration
		$this->cfg = new Config();

		// Initialize modules
		define('IRCD', $this->cfg->getParam('ircd_type'));
		/*if ($api_mode == "web" || $api_mode == "anope") {
			$this->anope = new Anope();
		}*/
		if ($api_mode == "web" || $api_mode == "denora") {
			$this->denora = new Denora();
		}

		if ($api_mode == "web") {
			// Set the locale
			$locale = $this->cfg->getParam('locale');
			$domain = "messages";
			/*if (!ini_get("safe_mode")) {
				putenv("LC_ALL={$locale}.utf8");
			}*/
			setlocale(LC_ALL, $locale);
			bindtextdomain($domain, './locale/');
			bind_textdomain_codeset($domain, "UTF-8");
			textdomain($domain);
			#define('LANG', substr($locale, 0, 2));
		}
	}

	/**
	 * Gets the page content for the specified name
	 * @param string $name Content identifier
	 * @return string HTML content
	 */
	function getContent($name) {
		$ps = $this->db->prepare("SELECT text FROM magirc_content WHERE name = :name");
		$ps->bindParam(':name', $name, PDO::PARAM_STR);
		$ps->execute();
		return $ps->fetch(PDO::FETCH_COLUMN);
	}

	/**
	 * Checks thet permission for the given type and target.
	 * Terminates the program with an appropriate error message on failure.
	 * (Used by the RESTful API)
	 * @param string $type Choices: 'channel'
	 * @param string $target For example the channel name
	 */
	function checkPermission($type, $target) {
		$result = 200;
		switch($type) {
			case 'channel':
				$result = $this->denora->checkChannel($target);
				break;
		}
		// In case of error the application will terminate, otherwise it will continue normally
		switch ($result) {
			case 404: $this->slim->notFound();
			case 403: $this->slim->halt(403, $this->jsonOutput(array('error' => "HTTP 403 Access Denied")));
		}
	}

	/**
	 * Encodes the given data as a JSON object.
	 * (Used by the RESTful API)
	 * @param mixed $data Data
	 * @param boolean $datatables allow/forbid DataTables format
	 * @param string $idcolumn Column name to use as index for the DataTables automatic row id. If not specified, the first column will be used.
	 */
	function jsonOutput($data, $datatables = false, $idcolumn = null) {
		if ($datatables && @$_GET['format'] == "datatables") {
			if (!$idcolumn && count($data) > 0) $idcolumn = key($data[0]);
			foreach ($data as $key => $val) {
				if (is_array($data[$key])) $data[$key]["DT_RowId"] = $val[$idcolumn];
				else $data[$key]->DT_RowId = $val->$idcolumn;
			}
			echo json_encode(array('aaData' => $data));
		} else {
			echo json_encode($data);
		}
	}

	/**
	 * Returns the session status
	 * @return boolean true: valid session, false: invalid or no session
	 */
	function sessionStatus() {
		if (!isset($_SESSION["loginUsername"])) {
			$_SESSION["message"] = "Access denied";
			return false;
		}
		if (!isset($_SESSION["loginIP"]) || ($_SESSION["loginIP"] != $_SERVER["REMOTE_ADDR"])) {
			$_SESSION["message"] = "Access denied";
			return false;
		}
		return true;
	}

	/**
	 * Returns the given text with html tags for colors and styling
	 * @global string $charset
	 * @param string $text IRC text
	 * @return string HTML text
	 */
	public static function irc2html($text) {
		global $charset;
		$lines = explode("\n", utf8_decode($text));
		$out = '';

		foreach ($lines as $line) {
			$line = nl2br(htmlentities($line, ENT_COMPAT, $charset));
			// replace control codes
			$line = preg_replace_callback('/[\003](\d{0,2})(,\d{1,2})?([^\003\x0F]*)(?:[\003](?!\d))?/', function($matches) {
						$colors = array('#FFFFFF', '#000000', '#00007F', '#009300', '#FF0000', '#7F0000', '#9C009C', '#FC7F00', '#FFFF00', '#00FC00', '#009393', '#00FFFF', '#0000FC', '#FF00FF', '#7F7F7F', '#D2D2D2');
						$options = '';

						if ($matches[2] != '') {
							$bgcolor = trim(substr($matches[2], 1));
							if ((int) $bgcolor < count($colors)) {
								$options .= 'background-color: ' . $colors[(int) $bgcolor] . '; ';
							}
						}

						$forecolor = trim($matches[1]);
						if ($forecolor != '' && (int) $forecolor < count($colors)) {
							$options .= 'color: ' . $colors[(int) $forecolor] . ';';
						}

						if ($options != '') {
							return '<span style="' . $options . '">' . $matches[3] . '</span>';
						} else {
							return $matches[3];
						}
					}, $line);
			$line = preg_replace('/[\002]([^\002\x0F]*)(?:[\002])?/', '<strong>$1</strong>', $line);
			$line = preg_replace('/[\x1F]([^\x1F\x0F]*)(?:[\x1F])?/', '<span style="text-decoration: underline;">$1</span>', $line);
			$line = preg_replace('/[\x12]([^\x12\x0F]*)(?:[\x12])?/', '<span style="text-decoration: line-through;">$1</span>', $line);
			$line = preg_replace('/[\x16]([^\x16\x0F]*)(?:[\x16])?/', '<span style="font-style: italic;">$1</span>', $line);
			$line = preg_replace('@(https?://([-\w\.]+)+(:\d+)?(/([\S+]*(\?\S+)?)?)?)@', "<a href='$1' class='topic'>$1</a>", $line);
			// remove dirt
			$line = preg_replace('/[\x00-\x1F]/', '', $line);
			$line = preg_replace('/[\x7F-\xFF]/', '', $line);
			// append line
			if ($line != '') {
				$out .= $line;
			}
		}

		return $out;
	}

}

?>