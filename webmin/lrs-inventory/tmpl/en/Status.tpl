<link rel='StyleSheet' href='/lrs-inventory/css/main.css' type='text/css' media='screen' />

<div  style="text-align: right;">
<form>
Clients without inventory since: 
<input type="checkbox" name="cb" onClick="since.value=0" checked /> always or more than
<input type="text" name="since" onKeyDown="cb.checked=0" value="{SINCE}" size=3 /> days.
</from>
</div>
<p>
	<h3>Clients without Windows/MAC OS/Linux inventory</h3>
		
	<ul>	
	<!-- BEGIN row -->			
	<li><a href="general.cgi?host={HOST}">{HOST}</a> {DATE}</li>
	<!-- END row -->
	</ul>

	<h3>Clients without boot inventory</h3>
		
	<ul>	
	<!-- BEGIN rowboot -->
	<li><a href="general.cgi?host={HOST}">{HOST}</a> {DATE}</li>
	<!-- END rowboot -->
	</ul>
	
	</div>

</p>