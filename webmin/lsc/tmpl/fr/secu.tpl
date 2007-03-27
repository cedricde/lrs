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
    <h1><a href="properties.cgi?mac={MAC}&pwd={PWD_UP}&file={FILENAME}"><img src="images/actions/up.png" /></a>
        {CUR_DIR} (s&eacute;curit&eacute; avanc&eacute;e)</h1>
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
           <form action="secu.cgi?mac={MAC}&action=rename&pwd={PWD}&file={FILENAME}" method="POST">
             <input type="text" value="{FILENAME}" name="newname"><input type="image" src="images/button_ok.png" />
           </form>
         </td>
         <td class="group_iconified">
           <a href="secu.cgi?mac={MAC}&action=show&pwd={PWD}&file={FILENAME}"><img src="images/actions/fileopen.png" title="T&eacute;l&eacute;charger/Afficher"></a>
           <a href="secu.cgi?mac={MAC}&action=suppr&pwd={PWD}&file={FILENAME}"><img src="images/actions/delete.png" title="Supprimer"></a>
           <a href="secu.cgi?mac={MAC}&action=exec&pwd={PWD}&file={FILENAME}"><img src="images/actions/run.png" title="Executer"></a>
         </td>
       </tr>
     </table>
   </div>
   <form name="form_acl" action="secu.cgi?mac={MAC}&pwd={PWD}&file={FILENAME}" method="POST"
    OnSubmit="if (this.action.value == 'cancel') { this.reset(); return (false); } return (true);">
   <div id="sshd_info">   
     <div id="sshd_info_perms">
       <!-- BEGIN BLOCK_USER_PERM -->
       <h1>{ACL_USER}</h1>
       <table>
         <tr>
           <th></th>
           <th>Autoriser</th>
           <th>Refuser</th>
         </tr>
         <tr>
           <td class="left">Cont&ocirc;le total</td>
           <td><input type="checkbox" name="mods[{ACL_USER}][F_accept]" {F_ACCEPT}
              onClick="if (this.checked == true) document.form_acl.elements[{ID_1}].checked = false;" /></td>
           <td><input type="checkbox" name="mods[{ACL_USER}][F_deny]" {F_DENY} 
              onClick="if (this.checked == true) document.form_acl.elements[{ID_0}].checked = false;" /></td>
         </tr>
         <tr>
           <td class="left">Modifier</td>
           <td><input type="checkbox" name="mods[{ACL_USER}][D_accept]" {D_ACCEPT} 
              onClick="if (this.checked == true) document.form_acl.elements[{ID_3}].checked = false;" /></td>
           <td><input type="checkbox" name="mods[{ACL_USER}][D_deny]" {D_DENY} 
              onClick="if (this.checked == true) document.form_acl.elements[{ID_2}].checked = false;" /></td>
         </tr>
         <tr>
           <td class="left">Lecture et ex&eacute;cution</td>
           <td><input type="checkbox" name="mods[{ACL_USER}][X_accept]" {X_ACCEPT} 
              onClick="if (this.checked == true) document.form_acl.elements[{ID_5}].checked = false;" /></td>
           <td><input type="checkbox" name="mods[{ACL_USER}][X_deny]" {X_DENY} 
              onClick="if (this.checked == true) document.form_acl.elements[{ID_4}].checked = false;" /></td>
         </tr>
         <tr>
           <td class="left">Lecture</td>
           <td><input type="checkbox" name="mods[{ACL_USER}][R_accept]" {R_ACCEPT} 
              onClick="if (this.checked == true) document.form_acl.elements[{ID_7}].checked = false;" /></td>
           <td><input type="checkbox" name="mods[{ACL_USER}][R_deny]" {R_DENY} 
              onClick="if (this.checked == true) document.form_acl.elements[{ID_6}].checked = false;" /></td>
         </tr>
         <tr>
           <td class="left">&Eacute;criture</td>
           <td><input type="checkbox" name="mods[{ACL_USER}][W_accept]" {W_ACCEPT} 
              onClick="if (this.checked == true) document.form_acl.elements[{ID_9}].checked = false;" /></td>
           <td><input type="checkbox" name="mods[{ACL_USER}][W_deny]" {W_DENY} 
              onClick="if (this.checked == true) document.form_acl.elements[{ID_8}].checked = false;" /></td>
         </tr>
       </table>
       <a href="secu_more.cgi?mac={MAC}&pwd={PWD}&file={FILENAME}&acl_user={ACL_USER}">Plus d'options ...&gt;</a>
       <!-- END BLOCK_USER_PERM -->
     </div>
   </div>
   <div class="sshd_info" id="sshd_exp_advactions"> 
       <select name="action">
         <option value="apply">Appliquer les modifications</option>
         <option value="cancel">Annuler les modifications</option>
<!--         <option value="show">Afficher/t&eacute;l&eacute;charger</option>
         <option value="copy">Copier</option>
         <option value="move">D&eacute;placer</option>
         <option value="ln">Cr&eacute;er raccourci</option>
         <option value="suppr">Supprimer</option> -->
       </select>
       <input type="image" src="images/button_ok.png" />
   </div>
   <hr />
 </div>
 </form>

