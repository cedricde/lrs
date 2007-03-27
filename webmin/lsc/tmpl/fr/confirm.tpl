<style type="text/css">
  @import url("css/lsc.css");
</style>

<div id="sshd_center">

  <div id="sshd_exp_header">
    <h1>{REMOTE_USER}@{CLIENT} ({PLATFORM})</h1>
  </div>

  <div id="lsc_msg">
    <p><span class="lettrine"><img src="images/{MSG_TYPE}.png" /></span>{MSG}</p>
    <form>
      <input type="submit" value="Oui" />
    </form>
    <form>
      <input type="submit" value="Non" />
    </form>
  </div>
</div>
