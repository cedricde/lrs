<!-- BEGIN section_menu -->
        <style type="text/css">
                @import url("/lbs_common/css/tabs.css");
        </style>
<!-- BEGIN ligne -->
        <ul id="lbsonglet">
<!-- BEGIN case -->
<!-- BEGIN etat:plein -->
                <li class="bouton_{IS_SELECTED}">
                        <div class='bouton_{IS_SELECTED}'>
				<a class="{IS_SELECTED}" href="{URL}">
					{NOM_LIEN}
				</a>
			</div>
                </li>
<!-- END etat:plein -->
<!-- BEGIN etat:vide -->
                <li class="bouton_{IS_SELECTED}">
                        <div class='bouton_{IS_SELECTED}'>
				<a class="">
					{NOM_LIEN}
				</a>
                        </div>
                </li>
<!-- END etat:vide -->
<!-- END case -->	
        </ul>
        <div class="cadre">
<!-- END ligne -->
<!-- END section_menu -->
<!-- BEGIN fin_menu -->
        </div>
<!-- END fin_menu -->
        