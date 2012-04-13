<div id="welcome"><h1>Live Network Status</h1></div>

<table class="details" style="width:100%;">
	<tr>
		<th colspan="2"><h3>Users</h3></th>
		<th colspan="2"><h3>Channels</h3></th>
		<th colspan="2"><h3>Operators</h3></th>
		<th colspan="2"><h3>Servers</h3></th>
	</tr>
	<tr>
		<th>Current:</th><td><span id="net_users" class="val"></span></td>
		<th>Current:</th><td><span id="net_chans" class="val"></span></td>
		<th>Current:</th><td><span id="net_opers" class="val"></span></td>
		<th>Current:</th><td><span id="net_servers" class="val"></span></td>
	</tr>
	<tr>
		<th>Peak:</th><td><span id="net_users_max" class="val"></span> on <span id="net_users_max_time"></span></td>
		<th>Peak:</th><td><span id="net_chans_max" class="val"></span> on <span id="net_chans_max_time"></span></td>
		<th>Peak:</th><td><span id="net_opers_max" class="val"></span> on <span id="net_opers_max_time"></span></td>
		<th>Peak:</th><td><span id="net_servers_max" class="val"></span> on <span id="net_servers_max_time"></span></td>
	</tr>
	<tr>
		<th>Today:</th><td><span id="net_users_today" class="val"></span> on <span id="net_users_today_time"></span></td>
		<td colspan="2" rowspan="3">&nbsp;</td>
	</tr>
</table>

<table>
	<tr>
		<td><div id="chart_users" style="height: 175px; width: {if $cfg.service_searchirc}446{else}560{/if}px;"></div></td>
		<td><div id="chart_status" style="height: 175px; width: 280px;"></div></td>
		{if $cfg.service_searchirc}<td style="width: 114px; margin: auto; vertical-align: top; text-align: center;">
			<img height="40" width="114" border="0" alt="Overall_Ranking" src="http://searchirc.com/img/ranked_logo.gif">
			<br /><a target="_blank" href="http://searchirc.com/rank/{$cfg.service_searchirc}">Teranova</a>
			<br /><span id="searchirc_ranking"></span>
		</td>{/if}
	</tr>
</table>

<table class="details" style="width:100%;">
	<tr>
		<th style="width:33%;"><h3>Current 10 Biggest Chans</h3></th>
		<th style="width:33%;"><h3>Top 10 Channels Today</h3></th>
		<th style="width:33%;"><h3>Top 10 Users Today</h3></th>
	</tr>
	<tr>
		<td valign="top">
			<table id="tbl_biggestchans" class="display clickable">
				<thead>
					<tr>
						<th>Channel</th>
						<th>Users</th>
					</tr>
				</thead>
				<tbody>
					<tr>
						<td colspan="2">Loading...</td>
					</tr>
				</tbody>
			</table>
		</td>
		<td valign="top">
			<table id="tbl_top10chans" class="display clickable">
				<thead>
					<tr>
						<th>Channel</th>
						<th>Lines</th>
					</tr>
				</thead>
				<tbody>
					<tr>
						<td colspan="2">Loading...</td>
					</tr>
				</tbody>
			</table>
		</td>
		<td valign="top">
			<table id="tbl_top10users" class="display clickable">
				<thead>
					<tr>
						<th>User</th>
						<th>Lines</th>
					</tr>
				</thead>
				<tbody>
					<tr>
						<td colspan="2">Loading...</td>
					</tr>
				</tbody>
			</table>
		</td>
	</tr>
</table>
{jsmin}
<script type="text/javascript"><!--
var refresh_interval = {$cfg.live_interval};
var welcome_msg = '{$cfg.welcome_mode}';
var searchirc = '{$cfg.service_searchirc}';
{literal}
$(document).ready(function() {
	if (welcome_msg == 'statuspage') {
		$.get('index.php/content/welcome', function(result) {
			$("#welcome").html(result);
		});
	}
	var count = 0;

	var chart_users = new Highcharts.Chart({
		chart: { type: 'area', renderTo: 'chart_users', events: { load: startCron() } },
		yAxis: { title: { text: null } },
		series: [{ name: 'Servers', data: initData(), visible:false }, { name: 'Channels', data: initData(), visible:false }, { name: 'Users', data: initData() }, { name: 'Operators', data: initData(), visible:false }],
		legend: { enabled: true }
	});
	var chart_status = new Highcharts.Chart({
		chart: { renderTo: 'chart_status', type: 'column', events: { load: startCron() } },
		xAxis: { type: 'linear', categories: [ 'Users', 'Channels', 'Operators', 'Servers' ], labels: { rotation: -45, align: 'right' } },
		yAxis: { min: 0, title: { text: null } },
		tooltip: { formatter: function() { return '<b>'+ this.x +'</b>: '+ Highcharts.numberFormat(this.y, 0); } },
		series: [{ name: 'Status', data: [0, 0, 0] }]
	});

	function startCron() {
		count++;
		if (count >= 2) {
			updateStatus();
			updateMax();
			if (refresh_interval > 0) {
				setInterval(updateStatus, refresh_interval * 1000);
				setInterval(updateTables, refresh_interval * 1000);
			}
		}
	}
	function updateStatus() {
		$.getJSON('rest/denora.php/network/status', function(result) {
			var x = (new Date()).getTime();
			chart_users.series[0].addPoint([x, result.servers.val], true, true);
			chart_users.series[1].addPoint([x, result.chans.val], true, true);
			chart_users.series[2].addPoint([x, result.users.val], true, true);
			chart_users.series[3].addPoint([x, result.opers.val], true, true);
			chart_status.series[0].setData([result.users.val, result.chans.val, result.opers.val, result.servers.val]);
			$("#net_users").html(result.users.val);
			if ($("#net_users").html() > $("#net_users_max")) {
				$("#net_users_max").html(result.users.val);
				$("#net_users_max_time").html($.format.date(result.users.time, format_datetime));
			}
			$("#net_users_today").html(result.daily_users.val);
			$("#net_users_today_time").html($.format.date(result.daily_users.time, format_datetime));
			$("#net_chans").html(result.chans.val);
			if ($("#net_chans").html() > $("#net_chans_max")) {
				$("#net_chans_max").html(result.chans.val);
				$("#net_chans_max_time").html($.format.date(result.chans.time, format_datetime));
			}
			$("#net_servers").html(result.servers.val);
			if ($("#net_servers").html() > $("#net_servers_max")) {
				$("#net_servers_max").html(result.servers.val);
				$("#net_servers_max_time").html($.format.date(result.servers.time, format_datetime));
			}
			$("#net_opers").html(result.opers.val);
			if ($("#net_opers").html() > $("#net_opers_max")) {
				$("#net_opers_max").html(result.opers.val);
				$("#net_opers_max_time").html($.format.date(result.opers.time, format_datetime));
			}
		});
	}
	function updateMax() {
		$.getJSON('rest/denora.php/network/max', function(result) {
			$("#net_users_max").html(result.users.val);
			$("#net_chans_max").html(result.channels.val);
			$("#net_servers_max").html(result.servers.val);
			$("#net_opers_max").html(result.opers.val);
			$("#net_users_max_time").html($.format.date(result.users.time, format_datetime));
			$("#net_chans_max_time").html($.format.date(result.channels.time, format_datetime));
			$("#net_servers_max_time").html($.format.date(result.servers.time, format_datetime));
			$("#net_opers_max_time").html($.format.date(result.opers.time, format_datetime));
		});
	}
	function updateTables() {
		oTable1.fnReloadAjax();
		oTable2.fnReloadAjax();
		oTable3.fnReloadAjax();
	}
	function initData() {
		var data = [], time = (new Date()).getTime();
		for (i = -19; i <= 0; i++) {
			data.push({ x: time + i * refresh_interval * 1000, y: null });
		}
		return data;
	}
	$.extend($.fn.dataTable.defaults, {
        "bProcessing": false,
		"bFilter": false,
		"bInfo": false,
		"bLengthChange": false,
		"bPaginate": false,
		"bSort": false,
		"bEscapeRegex": false
    });
	oTable1 = $("#tbl_biggestchans").dataTable({
		"sAjaxSource": "rest/denora.php/channels/biggest/10?format=datatables",
		"aoColumns": [
			{ "mDataProp": "channel" },
			{ "mDataProp": "users" }
		]
	});
	$("#tbl_biggestchans tbody tr").live("click", function(event) {
		window.location = url_base + 'channel/' + encodeURIComponent(this.id) + '/profile';
	});
	oTable2 = $("#tbl_top10chans").dataTable({
		"sAjaxSource": "rest/denora.php/channels/top/10?format=datatables",
		"aoColumns": [
			{ "mDataProp": "channel" },
			{ "mDataProp": "lines" }
		]
	});
	$("#tbl_top10chans tbody tr").live("click", function(event) {
		window.location = url_base + 'channel/' + encodeURIComponent(this.id) + '/profile#activity';
	});
	oTable3 = $("#tbl_top10users").dataTable({
		"sAjaxSource": "rest/denora.php/users/top/10?format=datatables",
		"aoColumns": [
			{ "mDataProp": "uname", "fnRender": function(oObj) {
				return getUserStatus(oObj.aData) + ' ' + getCountryFlag(oObj.aData) + ' ' + oObj.aData['uname'] + getUserExtra(oObj.aData);
			} },
			{ "mDataProp": "lines" }
		]
	});
	$("#tbl_top10users tbody tr").live("click", function(event) {
		window.location = url_base + 'user/stats:' + encodeURIComponent(this.id) + '/profile';
	});
	if (searchirc) {
		$("#searchirc_ranking").html($(".searchirc6").html());
	}
});
{/literal}
--></script>
{/jsmin}