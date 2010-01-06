{* $Id$ *}
{include file="_header.tpl"}

<div id="content">

<table class="list">
	<tr>
		<th>Channel</th>
		<th>Users</th>
		<th>Max</th>
		<th style="width:100%">Modes</th>
	<tr>
{foreach from=$chanlist item=item}
	{if $item.topic}<tr class="{cycle values="bg1, bg2" advance=false}">
	{else}<tr class="{cycle values="bg1, bg2" advance=true}">{/if}
		<td><a href="channel/?channel={$item.name|escape:'url'}">{$item.name}</a></td>
		<td>{$item.users}</td>
		<td>{$item.users_max}</td>
		<td>{if $item.modes}+{$item.modes}{else}&nbsp;{/if}</td>
	</tr>
	{if $item.topic}
	<tr class="{cycle advance=true}">
		<td colspan="4"><div>{$item.topic|irc2html}</div></td>
	</tr>
	{/if}
{foreachelse}
	<tr>
		<td colspan="4">No channels to list</td>
	</tr>
{/foreach}
</table>

</div>

{include file="_footer.tpl"}