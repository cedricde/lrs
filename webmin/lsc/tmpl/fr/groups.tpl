<style type="text/css">
  @import url("css/lsc.css");
                #menu_profile ul {
                        list-style-type         : none;
			margin			: 0;
			width			: 654px;
                }
                
                #menu_profile ul li {
                        display			: inline;
                        height                  : 21px;
                        background-color        : #FCF7F5;
                        border                  : 1px solid #EF4D21;
                }
                
                #menu_profile  ul li.profil_selected {
                        background-color        : #FCD3C2;
                }
                
                
                #menu_profile  a {
                        font                    : normal 12px fixed;
                        text-decoration         : none;
                        padding			: 5px;
		}
	
                #menu_profile a.profil_selected:hover {
                        color                   : darkgray;
                        border-bottom           : 1px dashed #EF4D21;
                }
                
                #menu_profile a.profil_unselected:hover {
                        color                   : darkgray;
                        background-color        : #FCD3C2;
                        border-bottom           : 1px dashed #EF4D21;
                }
</style>

<div id="sshd_center">

  <div id="sshd_exp_header">
    <h1>Profile : {CUR_PROFILE}</h1>
  </div>
  <div id="menu_profile">
    <ul>
      <!-- BEGIN MENU_PROFILES -->
      <li class="profil_selected">
        <a href="" class="profil_selected">{PROFILE_NAME}</a>
      </li>
      <!-- END MENU_PROFILES -->
    </ul>
  </div>
  <div id="sshd_dir_list">
    <!-- BEGIN ENUMDIR -->
    <ul>
    <!-- BEGIN ITEMDIR -->
      <li{DIR_OPEN}><a href="groups.cgi?group={LGROUP}&profile={LPROFIL}">{DIR_NAME}</a></li>
       {SUBDIR}
    <!-- END ITEMDIR --> 
    </ul>
      <!-- END ENUMDIR  -->
  </div>

  <div id="sshd_cur_dir">
    <h1><a href="group.cgi?profil={PROFIL}&group={GROUP_UP}}"><img src="images/actions/up.png" /></a> {GROUP}</h1>
  </div>
    <!-- BEGIN MESSAGE -->
  <div id="lsc_msg">
    <p><span class="lettrine"><img src="images/{MESS_ICON}.png" /></span>{MESS}</p>
  </div>
    <!-- END MESSAGE -->

   <div id="sshd_list_file">
     <table>
       <tr>
         <th class="iconified">Type</th>
         <th>Nom</th>
         <th class="group_iconified">Actions</th>
       </tr>
       <!-- BEGIN ROWFILE -->
       <tr class="{BACKGROUND_CLASS}">
         <td class="iconified"><img src="images/mimetypes/{ICON_MIMETYPE}" alt="{MIMETYPE}"></td>
         <td>{FILENAME}</td>
         <td class="group_iconified">
           <a href="groups.cgi?action=show&profile={LPROFIL}&group={LGROUP}"><img src="images/actions/run.png" title="Ex&eacute;cuter"></a>
           <img src="images/actions/edit.png" title="Editer">
           <img src="images/actions/editcopy.png" title="Copier">
           <img src="images/actions/delete.png" title="Supprimer">
         </td>
       </tr>
       <!-- END ROWFILE -->
      </table>
   </div>

   <div id="sshd_exp_advactions">
     <form method="GET">
       <input type="hidden" name="mac" value="{CUR_PORFILE}" />
       <input type="hidden" name="pwd" value="{CUR_GROUPE}" />
        <select name="system">
           <option value="reboot">Red&eacute;marrer le groupe/profile courant</option>
           <option value="halt">Arr&egrave;ter le groupe/profile courant</option>
        </select>
       <input type="image" src="images/button_ok.png" />
     </form>
   </div>
   <hr />
</div>
