//
// JS functions
//

function ChangeActionChoix(data)
{
   document.backuppc_configform.action = 'choix.cgi'+data;
   return true;
}

function addShare(sel, dest)
{
    var toadd = sel.value;
    if (toadd == "") return;
    // already added ?
    found = false;
    for (n=0; n < dest.length; n++) {
	if (dest.options[n].value == toadd) found = true;
    }
    if (found == false) {
	dest.options[dest.length] = new Option(toadd, toadd);
	dest.form.newshare.value = toadd;
    }
}

function delShare(dest)
{
    dest.remove(dest.selectedIndex);
}

function selectAllShares(dest)
{
    sel = "";
    for (n=0; n < dest.length; n++) {
	sel = sel + dest.options[n].value + "|";
    }
    dest.form.selshares.value = sel;
}
