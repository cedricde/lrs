<style type="text/css">
  @import url("css/lsc.css");
</style>

<div id="sshd_center">

  <div id="sshd_exp_header">
    <h1>{REMOTE_USER}@{CLIENT} ({PLATFORM})</h1>
  </div>

  <div id="lsc_confirm">
    <p><span class="lettrine"><img src="images/info.png" /></span>Entrer le chemin complet
      o&ugrave; copier <em>{CP_SRC}</em> :</p>
    <form method="GET">
      <input type="text" name="cp_dest" size="25"><br />
      <input type="checkbox" name="create" value="1"> Cr&eacute;er les r&eacute;pertoires parents si ils n'existent pas.<br />
      <input type="checkbox" name="overwrite" value="1"> Ecraser si le fichier existe.<br />
      <input type="hidden" name="confirm" value="ok" />
      <input type="hidden" name="mac" value="{MAC}" />
      <input type="hidden" name="pwd" value="{PWD}" />
      <input type="hidden" name="file" value="{FILE}" /> 
      <input type="submit" value="Copier" />
    </form>
  </div>
</div>
