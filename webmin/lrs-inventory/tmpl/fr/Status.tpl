<link rel='StyleSheet' href='/lrs-inventory/css/main.css' type='text/css' media='screen' />

<div  style="text-align: right;">
<form>
Clients sans inventaire depuis: 
<input type="checkbox" name="cb" onClick="since.value=0" checked /> toujours ou plus de
<input type="text" name="since" onKeyDown="cb.checked=0" value="{SINCE}" size=3 /> jours.
</from>
</div>
<p>
	<h3>Clients sans inventaire Windows/MAC OS/Linux</h3>
		
	<ul>	
	<!-- BEGIN row -->			
	<li><a href="general.cgi?host={HOST}">{HOST}</a> {DATE}</li>
	<!-- END row -->
	</ul>

	<h3>Clients sans inventaire au boot</h3>
		
	<ul>	
	<!-- BEGIN rowboot -->
	<li><a href="general.cgi?host={HOST}">{HOST}</a> {DATE}</li>
	<!-- END rowboot -->
	</ul>
	
	</div>

</p>