<!DOCTYPE html>
<html>
<head>
<title>{block name="title"}{$cfg.net_name} - {/block}</title>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<meta name="ROBOTS" content="NOINDEX, NOFOLLOW" />
<meta name="Keywords" content="MagIRC IRC Chat Statistics Denora stats phpDenora" />
<meta name="Description" content="IRC Statistics powered by MagIRC" />
<base href="{$smarty.const.BASE_URL}" />
{block name="css"}
<link href="css/styles.css" rel="stylesheet" type="text/css" />
<link href="css/jquery-ui.css" rel="stylesheet" type="text/css" />
<link href='http://fonts.googleapis.com/css?family=Share' rel='stylesheet' type='text/css'>
{/block}
</head>
<body>
{block name="body"}
<div id="header">
	<a href="./"><img src="img/magirc.png" alt="MagIRC" title="" id="logo" /></a>
	<div id="menu">
		<ul>
			<li><a href="index.php/overview"{if $section eq 'overview'} class="active"{/if}><span>&nbsp;Overview</span></a></li>
			<li><a href="index.php/denora"{if $section eq 'denora'} class="active"{/if}><span>&nbsp;Denora</span></a></li>
			<li><a href="index.php/support"{if $section eq 'support'} class="active"{/if}><span>&nbsp;Support</span></a></li>
		</ul>
	</div>
	<div id="loading"><img src="img/loading.gif" alt="loading..." /></div>
</div>
<div id="main">{block name="content"}[content placeholder]{/block}
</div>
<div id="footer">powered by <span style="font-size:12px;"><strong>MagIRC</strong></span> v{$smarty.const.VERSION_FULL}</div>
{/block}
{block name="js"}
<script type="text/javascript" src="http://ajax.aspnetcdn.com/ajax/jQuery/jquery-1.5.2.min.js"></script>
<script type="text/javascript" src="http://ajax.aspnetcdn.com/ajax/jquery.ui/1.8.18/jquery-ui.min.js"></script>
<script type="text/javascript" src="../js/jquery.form.js"></script>
{jsmin}
<script type="text/javascript"><!--
{literal}
var url_base = '{$smarty.const.BASE_URL}';
$(document).ready(function() {
	$("#loading").ajaxStart(function(){
		$(this).show();
	}).ajaxStop(function(){
		$(this).hide();
	});
});
{/literal}
--></script>
{/jsmin}
{/block}
</body>
</html>