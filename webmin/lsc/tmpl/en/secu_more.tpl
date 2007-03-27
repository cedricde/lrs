<style type="text/css">
  @import url("css/lsc.css");
</style>
<div id="sshd_center">
  <div class="cade">
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
       <h1><a href="secu.cgi?mac={MAC}&pwd={PWD_UP}&file={FILENAME}"><img src="images/actions/up.png" /></a> {CUR_DIR} (s&eacute;curit&eacute; avanc&eacute;e+)</h1>
      </div>
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
           <form action="secu_more.cgi?mac={MAC}&action=rename&pwd={PWD}&file={FILENAME}&acl_user={ACL_USER}" method="POST">
             <input type="text" value="{FILENAME}" name="newname"><input type="image" src="images/button_ok.png" />
           </form>
         </td>
           <td class="group_iconified">
             <a href="secu_more.cgi?mac={MAC}&action=show&pwd={PWD}&file={FILENAME}&acl_user={ACL_USER}"><img src="images/actions/fileopen.png" title="T&eacute;l&eacute;charger/Afficher"></a>
             <a href="secu_more.cgi?mac={MAC}&action=suppr&pwd={PWD}&file={FILENAME}&acl_user={ACL_USER}"><img src="images/actions/delete.png" title="Supprimer"></a>
             <a href="secu_more.cgi?mac={MAC}&action=exec&pwd={PWD}&file={FILENAME}&acl_user={ACL_USER}"><img src="images/actions/run.png" title="Executer"></a>
           </td>
         </tr>
       </table>
      </div>
     <form name="form_acl" action="secu_more.cgi?mac={MAC}&pwd={PWD}&file={FILENAME}&acl_user={ACL_USER}" method="POST"
      OnSubmit="if (this.action.value=='cancel') { this.reset(); return (false); } return (true);">
      <div id="sshd_info">
        <div id="sshd_info_perms">
           <h1>{ACL_USER}</h1>
           <table>
             <tr>
               <th></th>
               <th>Autoriser</th>
               <th>Refuser</th>
             </tr>
             <tr>
               <td class="left">Parcourir le dossier/ex&eacute;cuter le fichier</td>
               <td><input type="checkbox" name="mods[{ACL_USER}][X_accept]" {X_ACCEPT} 
                  onClick="if (this.checked == true) document.form_acl.elements[1].checked = false;" /></td>
               <td><input type="checkbox" name="mods[{ACL_USER}][X_deny]" {X_DENY}
                  onClick="if (this.checked == true) document.form_acl.elements[0].checked = false;"  /></td>
             </tr>
             <tr>
               <td class="left">Liste du dossier/lecture de donn&eacute;es</td>
               <td><input type="checkbox" name="mods[{ACL_USER}][Rr_accept]" {Rr_ACCEPT}
                  onClick="if (this.checked == true) document.form_acl.elements[3].checked = false;"  /></td>
               <td><input type="checkbox" name="mods[{ACL_USER}][Rr_deny]" {Rr_DENY}
                  onClick="if (this.checked == true) document.form_acl.elements[2].checked = false;" /></td>
             </tr>
             <tr>
               <td class="left">Attributs de lecture</td>
               <td><input type="checkbox" name="mods[{ACL_USER}][Ra_accept]" {Ra_ACCEPT}
                  onClick="if (this.checked == true) document.form_acl.elements[5].checked = false;" /></td>
               <td><input type="checkbox" name="mods[{ACL_USER}][Ra_deny]" {Ra_DENY}
                  onClick="if (this.checked == true) document.form_acl.elements[4].checked = false;"  /></td>
             </tr>
             <tr>
               <td class="left">Lire les attributs &eacute;tendus</td>
               <td><input type="checkbox" name="mods[{ACL_USER}][Re_accept]" {Re_ACCEPT} 
                  onClick="if (this.checked == true) document.form_acl.elements[7].checked = false;" /></td>
               <td><input type="checkbox" name="mods[{ACL_USER}][Re_deny]" {Re_DENY}
                  onClick="if (this.checked == true) document.form_acl.elements[6].checked = false;"  /></td>
             </tr>
             <tr>
               <td class="left">Cr&eacute;ation de fichiers/&eacute;criture de donn&eacute;es</td>
               <td><input type="checkbox" name="mods[{ACL_USER}][Ww_accept]" {Ww_ACCEPT} 
                  onClick="if (this.checked == true) document.form_acl.elements[9].checked = false;" /></td>
               <td><input type="checkbox" name="mods[{ACL_USER}][Ww_deny]" {Ww_DENY}
                  onClick="if (this.checked == true) document.form_acl.elements[8].checked = false;"  /></td>
             </tr>
             <tr>
               <td class="left">Cr&eacute;action de dossiers/Ajout de donn&eacute;es</td>
               <td><input type="checkbox" name="mods[{ACL_USER}][A_accept]" {A_ACCEPT} 
                  onClick="if (this.checked == true) document.form_acl.elements[11].checked = false;" /></td>
               <td><input type="checkbox" name="mods[{ACL_USER}][A_deny]" {A_DENY}
                  onClick="if (this.checked == true) document.form_acl.elements[10].checked = false;"  /></td>
             </tr>
             <tr>
               <td class="left">Attributs d'&eacute;criture</td>
               <td><input type="checkbox" name="mods[{ACL_USER}][Wa_accept]" {Wa_ACCEPT} 
                  onClick="if (this.checked == true) document.form_acl.elements[13].checked = false;" /></td>
               <td><input type="checkbox" name="mods[{ACL_USER}][Wa_deny]" {Wa_DENY}
                  onClick="if (this.checked == true) document.form_acl.elements[12].checked = false;"  /></td>
             </tr>
             <tr>
               <td class="left">&Eacute;criture d'attributs &eacute;tendu</td>
               <td><input type="checkbox" name="mods[{ACL_USER}][We_accept]" {We_ACCEPT} 
                  onClick="if (this.checked == true) document.form_acl.elements[15].checked = false;" /></td>
               <td><input type="checkbox" name="mods[{ACL_USER}][We_deny]" {We_DENY}
                  onClick="if (this.checked == true) document.form_acl.elements[14].checked = false;"  /></td>
             </tr>
             <tr>
               <td class="left">Suppression de sous dossiers et de fichiers</td>
               <td><input type="checkbox" name="mods[{ACL_USER}][Dc_accept]" {Dc_ACCEPT} 
                  onClick="if (this.checked == true) document.form_acl.elements[17].checked = false;" /></td>
               <td><input type="checkbox" name="mods[{ACL_USER}][Dc_deny]" {Dc_DENY}
                  onClick="if (this.checked == true) document.form_acl.elements[16].checked = false;"  /></td>
             </tr>
             <tr>
               <td class="left">Supprimer</td>
               <td><input type="checkbox" name="mods[{ACL_USER}][D_accept]" {D_ACCEPT} 
                  onClick="if (this.checked == true) document.form_acl.elements[19].checked = false;" /></td>
               <td><input type="checkbox" name="mods[{ACL_USER}][D_deny]" {D_DENY}
                  onClick="if (this.checked == true) document.form_acl.elements[18].checked = false;"  /></td>
             </tr>
             <tr>
               <td class="left">Autorisation de lecture</td>
               <td><input type="checkbox" name="mods[{ACL_USER}][p_accept]" {p_ACCEPT} 
                  onClick="if (this.checked == true) document.form_acl.elements[21].checked = false;" /></td>
               <td><input type="checkbox" name="mods[{ACL_USER}][p_deny]" {p_DENY}
                  onClick="if (this.checked == true) document.form_acl.elements[20].checked = false;"  /></td>
             </tr>
             <tr>
               <td class="left">modifier les autorisations</td>
               <td><input type="checkbox" name="mods[{ACL_USER}][P_accept]" {P_ACCEPT} 
                  onClick="if (this.checked == true) document.form_acl.elements[23].checked = false;" /></td>
               <td><input type="checkbox" name="mods[{ACL_USER}][P_deny]" {P_DENY}
                  onClick="if (this.checked == true) document.form_acl.elements[22].checked = false;"  /></td>
             </tr>
             <tr>
              <td class="left">Appropriation</td>
               <td><input type="checkbox" name="mods[{ACL_USER}][O_accept]" {O_ACCEPT} 
                  onClick="if (this.checked == true) document.form_acl.elements[25].checked = false;" /></td>
               <td><input type="checkbox" name="mods[{ACL_USER}][O_deny]" {O_DENY}
                  onClick="if (this.checked == true) document.form_acl.elements[24].checked = false;"  /></td>
             </tr>
           </table>
           <a href="secu.cgi?mac={MAC}&pwd={PWD}&file={FILENAME}">Moins d'options &lt;---</a>
        </div>
      </div>
      <div class="sshd_info" id="sshd_exp_advactions">
        <form>
          <select name="action">
            <option value="apply">Appliquer les modifications</option>
            <option value="cancel">Annuler les modifications</option>
<!--            <option value="show">Afficher/t&eacute;l&eacute;charger</option>
            <option value="copy">Copier</option>
            <option value="move">D&eacute;placer</option>
            <option value="link">Cr&eacute;er raccourci</option>
            <option value="suppr">Supprimer</option> -->
          </select>
          <input type="image" src="images/button_ok.png" />
      </div>
      </form>
      <hr />
    </div>
  </div>

