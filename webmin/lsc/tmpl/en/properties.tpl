<style type="text/css">
  @import url("css/lsc.css");
</style>


<div id="sshd_center">

  <div id="sshd_exp_header">
    <h1>{REMOTE_USER}@{CLIENT} ({PLATFORM})</h1>
  </div>

  <div id="sshd_dir_list">
    <!-- BEGIN ENUMDIR -->
    <ul>
    <!-- BEGIN ITEMDIR -->
      <li{DIR_OPEN}><a href="explorer.cgi?mac={MAC}&pwd={DIR_UP}">{DIR_NAME}</a></li>
       {SUBDIR}
    <!-- END ITEMDIR -->
    </ul>
      <!-- END ENUMDIR  -->
  </div>

  <div id="sshd_cur_dir">
    <h1><a href="explorer.cgi?mac={MAC}&pwd={PWD_UP}"><img src="images/actions/up.png" /></a> {CUR_DIR}</h1>
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
         <th class="iconified">Actions</th>
       </tr>
       <tr class="background0">
         <td><img src="images/mimetypes/{ICON_MIMETYPE}" alt="{MIMETYPE}"></td>
         <td>
           <form action="properties.cgi?mac={MAC}&action=rename&pwd={PWD}&file={FILENAME}" method="POST">
             <input type="text" value="{FILENAME}" name="newname"><input type="image" src="images/button_ok.png" />
           </form>
         </td>
         <td class="group_iconified">
           <a href="properties.cgi?mac={MAC}&action=show&pwd={PWD}&file={FILENAME}"><img src="images/actions/fileopen.png" title="T&eacute;l&eacute;charger/Afficher"></a>
           <a href="properties.cgi?mac={MAC}&action=suppr&pwd={PWD}&file={FILENAME}"><img src="images/actions/delete.png" title="Supprimer"></a>
           <a href="properties.cgi?mac={MAC}&action=exec&pwd={PWD}&file={FILENAME}"><img src="images/actions/run.png" title="Executer"></a>
         </td>
       </tr>
     </table>
   </div>
     <form name="form_properties" action="properties.cgi?mac={MAC}&pwd={PWD}&file={FILENAME}" method="POST"
     OnSubmit="if (this.action.value=='cancel') { this.reset(); return (false); } return (true);">
        <div id="sshd_info">
          <p>Taille<span><strong>{SIZE}</strong></span></p>
          <p>Modifié<span><strong>{CTIME}</strong></span></p>
          <p>Droits
            <span id ="sshd_info_perms">
              <table>
                <tr>
                  <td class="left">Lecture seule</td>
                  <td><input name="attrib[R]" type="checkbox" {R_CHECKED} /></td>
                </tr>
                <tr>
                  <td class="left">Archive</td>
                  <td><input name="attrib[A]" type="checkbox" {A_CHECKED} /></td>
                </tr>
		 <tr>
                  <td class="left">Syst&egrave;me</td>
                  <td><input name="attrib[S]" type="checkbox" {S_CHECKED} /></td>
                </tr>
                <tr>
                  <td class="left">Cach&eacute;</td>
                  <td><input name="attrib[H]" type="checkbox" {H_CHECKED} /></td>
                </tr>
                <tr>
                  <td class="left">Disponible pour les groupes et profiles</td>
                  <td><input name="grouped" type="checkbox" {FGROUPE_CHECKED} /></td>
                </tr>
              </table>
            </span><hr /><hr /><hr />
          </p>
          <div class="secu"><a href="secu.cgi?mac={MAC}&pwd={PWD}&file={FILENAME}">S&eacute;curit&eacute; avanc&eacute;e</a></div>
          <hr />
        </div>
        <div class="sshd_info" id="sshd_exp_advactions"> 
              <select name="action">
                <option value="apply">Appliquer les modifications</option>
                <option value="cancel">Annuler les modifications</option>
<!--                <option>Afficher/t&eacute;l&eacute;charger</option>
                <option>Copier</option>
                <option>D&eacute;placer</option>
                <option>Cr&eacute;er raccourci</option>
                <option>Supprimer</option> -->
              </select>
              <input type="image" src="images/button_ok.png" />
        </div>
      </form>
      <hr />
    </div>

