<!-- BEGIN mainlist -->
<script type="text/javascript" src="/lbs_common/js/tooltip.js"></script>
<div id="tooltip" style=" position: absolute; visibility: hidden;"></div>
<!-- BEGIN title -->
<center>
        <h2><b>{REGISTRED_CLIENTS}</b></h2>
</center>
<!-- END title -->

<!-- BEGIN searchform -->
<div style="text-align: right; position: absolute; top: 170px; right: 15px">
        <form action="search.cgi" method="GET" style="margin: 0px; ">
                <input type="hidden" name="searchkind" value="quick" />
                <input type="text" name="keyword" value="{QUICKSEARCH}" onclick="if (this.value == '{QUICKSEARCH}') {this.value = '';}" />
        </form>
        <small><a href="search.cgi">{ADVSEARCH}</a></small>
</div>
<!-- END searchform -->

<!-- BEGIN profils -->
        <style type="text/css" media='screen'><!--
                ul#lrsprofils {
                        list-style-type         : none;
                        padding-left            : 5px;
                        padding-bottom          : 25px;
                        border-bottom           : 1px solid #EF4D21;
                        margin                  : 0px;
                }
                
                ul#lrsprofils li {
                        float                   : left;
                        height                  : 21px;
                        background-color        : #FCF7F5;
                        margin                  : 3px 3px 0px 3px;
                        border                  : 1px solid #EF4D21;
                }
                
                ul#lrsprofils li.profil_selected {
                        border-bottom           : 1px solid #FCD3C2;
                        background-color        : #FCD3C2;
                }
                
                
                #lrsprofils a {
                        font                    : normal 12px fixed;
                        display                 : block;
                        text-decoration         : none;
                        margin                  : 0px;
                        padding                 : 6px;
                        padding-top             : 2px;
                        padding-bottom          : 5px;
                }
                
                #lrsprofils a.profil_selected:hover {
                        color                   : darkgray;
                        padding-bottom          : 4px;
                        border-bottom           : 1px dashed #EF4D21;
                }
                
                #lrsprofils a.profil_unselected:hover {
                        color                   : darkgray;
                        background-color        : #FCD3C2;
                        padding-bottom          : 4px;
                        border-bottom           : 1px dashed #EF4D21;
                }

                div.groups {
                        border                  : 1px solid #EF4D21;
                        border-top-width        : 0px;
                        padding                 : 0px;
                        margin 		        : 0px;
                        clear                   : left;
                }
                
                td.normalcell {
                        border-width            : 0px;
                        border-left             : 1px solid #FCD3C2;
                        padding-left            : 1em;
                        padding-right           : 1em;
                }
                
                td.firstcell {
                        border-width            : 0px;
                        padding-left            : 1em;
                        padding-right           : 1em;
                }
                
                td.topcell {
                        border                  : 0px solid #EF4D21;
                        font-size               : 10px;
                }
                
        --></style>
        <ul id="lrsprofils">
<!-- BEGIN profil -->
                <li class='profil_{IS_SELECTED}'>
                        <div class='profil_{IS_SELECTED}'>
				<a class='profil_{IS_SELECTED}' href='{URL}'>
					{PROFIL}
				</a>
                        </div>
                </li>
<!-- END profil -->	
        </ul>
        <div class="groups">

<!-- END profils -->

<!-- BEGIN starttable -->
        <table style="border: 0px solid white; padding: 0px; margin: 0px;">
<!-- END starttable -->
<!-- BEGIN toprow -->
                <tr>
<!-- BEGIN topcell -->
                        <td {TB} {ATTRIBS} class="topcell" NOWRAP><b>{TITLE}</b></td>
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

<!-- BEGIN moreactions -->
        <div align="left" style="width: 100%; background-color: #fcece5; border-top: 1px solid #FCD3C2">
        <table width="1" style="border-width: 0px; padding: 5px; margin-left: 1px;">
                <tr style="">
                <td style="vertical-align: top; font-weight: bold; border-width: 0px;" nowrap>{ACTIONONCURRENTPROF}</td>
<!-- BEGIN uppercell -->
                <td style="border-width: 0px;" nowrap>{CONTENT}</td>
<!-- END uppercell -->
                <td style="border-width: 0px; width: 100%;"><div style="width: 100%;">&nbsp;</div></td>
                </tr>
        </table>
        </div>

        </div>
<!-- END moreactions -->
<!-- END endtable -->
<!-- END mainlist -->