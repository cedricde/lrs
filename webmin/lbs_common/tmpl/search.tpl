<!-- BEGIN resultslist -->
<script type="text/javascript" src="/lbs_common/js/tooltip.js"></script>
<div id="tooltip" style=" position: absolute; visibility: hidden;"></div>
<!-- BEGIN title -->
<center>
<h2><b>{SEARCHRESULTS}</b></h2>
<!-- END title -->

<!-- BEGIN starttable -->
        <table style="border: 0px solid white; padding: 0px; margin: 0px; width: 80%">
<!-- END starttable -->
<!-- BEGIN toprow -->
                <tr>
<!-- BEGIN topcell -->
                        <td {TB} {ATTRIBS} class="topcell" NOWRAP align="center"><b>{TITLE}</b></td>
<!-- END topcell -->
                </tr>
<!-- END toprow -->
<!-- BEGIN normalrow -->
                <tr {ROWSTYLE} style="border-width: 0px;">
<!-- BEGIN firstcell -->
                        <td {FIRSTCELLARGS} class="firstcell"><div style="whitespace: nowrap">{CONTENT}</div></td>
<!-- END firstcell -->
<!-- BEGIN normalcell -->
                        <td {ATTRIBS} class="normalcell">{CONTENT}</td>
<!-- END normalcell -->
                </tr>
<!-- END normalrow -->
<!-- BEGIN endtable -->
        </table>

<!-- END endtable -->
</center>
<a href="search.cgi">{OTHERSEARCH}</a>
<!-- END resultslist -->

<!-- BEGIN searchform -->
<center>
<h2><b>{SEARCHQUERY}</b></h2>
        <form action="" method="GET">
                <table style="border: 0px solid white; padding: 0px; margin: 0px;">
                        <tr style="border-width: 0px;"><td style="border-width: 0px;">{PROFILE}</td><td style="border-width: 0px;"><input type="text" name="profile" value="" /></td></tr>
                        <tr style="border-width: 0px;"><td style="border-width: 0px;">{GROUP}</td><td style="border-width: 0px;"><input type="text" name="group" value="" /></td></tr>
                        <tr style="border-width: 0px;"><td style="border-width: 0px;">{NAME}</td><td style="border-width: 0px;"><input type="text" name="name" value="" /></td></tr>
                        <tr style="border-width: 0px;"><td style="border-width: 0px;">{MAC}</td><td style="border-width: 0px;"><input type="text" name="mac" value="" /></td></tr>
                </table>
                <input type="hidden" name="searchkind" value="normal" />
                <input type="submit" name="" value="{SEARCH}" />
        </form>
<!-- END searchform -->