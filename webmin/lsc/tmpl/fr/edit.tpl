<style type="text/css">
  @import url("css/lsc.css");
</style>

<div id="sshd_center">

  <div id="sshd_exp_header">
    <h1>{REMOTE_USER}@{CLIENT} ({PLATFORM})</h1>
  </div>
 
 <div id="edit_cadre">
   <p>Fichier : {FILENAME}
   <form method="POST" action="edit.cgi?mac={MAC}&action=editpost&pwd={PWD}&file={FILE}">
     <textarea name="content" cols="80" rows="25">{CONTENT}</textarea>
     <input type="submit" value=" Enregistrer ">
   </form>
    
 </div>
</div>
