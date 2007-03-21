<script type="text/javascript" language="JavaScript" src="backuppc.js"></script>
<style media="screen" type="text/css">
.warning { border: 2px solid red;}
.select { width: 250px; }
.shareform { width: 500px; margin:0px auto; }
.shareform td { border-style: none; }
.shareform table { border-style: solid;
border-width: 1px;
padding: 10px;
}
</style>
<div class="shareform">

<!-- BEGIN warning_row -->
<p class="warning">{EMPTY_LIST}</p>
<!-- END warning_row -->

<FORM METHOD="post" ACTION="host_config.cgi{GET_DATA}">
<INPUT TYPE="hidden" NAME="username" VALUE="{USERNAME}">
<INPUT TYPE="hidden" NAME="passwd" VALUE="{PASSWD}">
<INPUT TYPE="hidden" NAME="mac" VALUE="{MAC}">
<INPUT TYPE="hidden" NAME="host" VALUE="{HOST}">
<INPUT TYPE="hidden" NAME="selshares" VALUE="">

<table style="width: 100%;">
<tbody>
<tr>
<td style="width: 50%; text-align: center;">{TEXT_AVAIL_SHARES}:</td>
<td style="width: 50%; text-align: center;">{TEXT_SELECTED_SHARES}:</td>
</tr>
<tr>
<td>
<select class="select" size="10" name="available" onClick="addShare(this.form.available, this.form.shares);">
<!-- BEGIN found_share_row -->
<OPTION VALUE="{SHARE}">{SHARE}</OPTION>
<!-- END found_share_row -->
</select>
</td>
<td>
<select class="select" size="10" name="shares" onChange="delShare(this.form.shares);" >
<!-- BEGIN added_share_row -->
<OPTION VALUE="{SHARE}">{SHARE}</OPTION>
<!-- END added_share_row -->
</select>
</td>
</tr>
<tr>
<td><input name="newshare" size="20"><input name="addshare" value="{TEXT_ADD}" type="button" onClick="addShare(this.form.newshare, this.form.shares);"></td>
<td style="text-align: right"><input name="submit" value="{TEXT_SUBMIT}" type="submit" onClick="selectAllShares(this.form.shares);"></td>
</tr>
</tbody>
</table>
</form>
</div>
