<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
  <title>Sitechecker</title>
  <meta http-equiv="content-type" content="text/html; charset=ISO-8859-1">
</head>
<!-- $Id: site.tpl 2164 2005-03-17 14:28:03Z jaudin $ -->
{HEADER}
<div align="Center">
<h1>Etat du site</h1>
<h4>{SITE}</h4>
<hr width="100%" size="2"><br>
<div align="Left">
<table cellpadding="2" cellspacing="2" border="1" width="100%">
  <tbody>
    <tr align="Center">
      <td valign="Top"><b>Date</b><br>
      </td>
      <td valign="Top"><b>Etat</b><br>
      </td>
      <td valign="Top"><b>Octets recus</b> <br>
      </td>
      <td valign="Top"><b>Dur&eacute;e</b><br>
      </td>
      <td valign="Top"><b>Etat Http</b><br>
      </td>
      <td valign="Top"><b>Erreur DNS</b><br>
      </td>
      <td valign="Top"><b>BM</b><br>
      </td>
      <td valign="Top"><b>MM</b><br>
      </td>
      <td valign="Top"><b>ET</b><br>
      </td>
      <td valign="Top"><b>ED</b><br>
      </td>
    </tr>
<!-- BEGIN status_row -->
    <tr>
      <td valign="Top">{DATE}<br>
      </td>
      <td valign="Top" align="Center"><img src='{STATUS}'></td>
      <td valign="Top" align="Right">{BYTES}<br>
      </td>
      <td valign="Top" align="Right">{TIME} ms<br>
      </td>
      <td valign="Top" align="Center">{HTTP}<br>
      </td>
      <td valign="Top" align="Center">{DNS}<br>
      </td>
      <td valign="Top" align="Center">{GW}<br>
      </td>
      <td valign="Top" align="Center">{BW}<br>
      </td>
      <td valign="Top" align="Center">{SE}<br>
      </td>
      <td valign="Top" align="Center">{TE}<br>
      </td>
    </tr>
<!-- END status_row -->
  </tbody>
</table>
<br>
<small><small>BM: Erreur sur les Bons Mots Cl&eacute;s. Les Bons Mots Cl&eacute;s
demand&eacute;s ne sont pas pr&eacute;sents dans la page.</small></small><br>
<small><small>MM: Erreur sur les Mauvais Mots Cl&eacute;s.
Un ou plusieurs Mauvais Mots Cl&eacute;s sp&eacute;cifi&eacute;s sont pr&eacute;sents
dans la page.</small></small><br>
<small><small>ET: Erreur de Taille. La page recue est plus
petite que la taille minimale sp&eacute;cifi&eacute;e.</small></small><br>
<small><small>ED: Erreur de Dur&eacute;e. La page a mis plus
de temps pour etre recue que la valeur maximale sp&eacute;cifi&eacute;e,</small></small><small><small><br>
</small></small><br><br>
Etat HTTP:<br>
<small><small>200: OK:
La requ�te HTTP a �t� trait�e avec succ�s.
</small></small><br>
<small><small>201: Cr��:
 La requ�te a �t� correctement trait�e et a r�sult� en la cr�ation d'une nouvelle ressource.
</small></small><br>
<small><small>202: Accept�:
La requ�te a �t� accept�e pour �tre trait�e, mais son traitement peut ne pas avoir abouti.
</small></small><br>
<small><small>203: Information non certifi�e:
 L'information retourn�e n'a pas �t� g�n�r�e par le serveur HTTP mais par une autre source non authentifi�e.
</small></small><br>
<small><small>204: Pas de contenu:
 Le serveur HTTP a correctement trait� la requ�te mais il n'y a pas d'information � envoyer en retour.
</small></small><br>
<small><small>205: Contenu r�initialis�: Le client doit remettre � z�ro le formulaire utilis� dans cette transaction.
</small></small><br>
<small><small>206: Contenu partiel: Le serveur retourne une partie seulement de la taille demand�e.
</small></small><br>
<small><small>300: Choix multiples: L'URI demand�e concerne plus d'une ressource.
</small></small><br>
<small><small>301: Changement d'adresse d�finitif: La ressource demand�e poss�de une nouvelle adresse (URI).
</small></small><br>
<small><small>302: Changement d'adresse temporaire: La ressource demand�e r�side temporairement � une adresse (URI) diff�rente.
</small></small><br>
<small><small>303: Voir ailleurs: L'URI sp�cifi� est disponible � un autre URI et doit �tre demand� par un GET.
</small></small><br>
<small><small>304: Non modifi�: Le navigateur web a effectu� une requ�te GET conditionnelle et l'acc�s est autoris�, mais le document n'a pas �t� modifi�.
</small></small><br>
<small><small>305: Utiliser le proxy: L'URI sp�cifi� doit �tre acc�d� en passant par le proxy.
</small></small><br>
<small><small>400: Mauvaise requ�te La requ�te HTTP n'a pas pu �tre comprise par le serveur en raison d'une syntaxe erron�e.
</small></small><br>
<small><small>401: Non autoris� La requ�te n�cessite une identification de l'utilisateur.
</small></small><br>
<small><small>403: Interdit Le serveur HTTP a compris la requ�te, mais refuse de la traiter.
</small></small><br>
<small><small>404: Non trouv� Le serveur n'a rien trouv� qui corresponde � l'adresse (URI) demand�e.
</small></small><br>
<small><small>405: M�thode non autoris�e Ce code indique que la m�thode utilis�e par le client n'est pas support�e pour cet URI.
</small></small><br>
<small><small>406: Aucun disponible L'adresse (URI) sp�cifi�e existe, mais pas dans le format pr�f�r� du client.
</small></small><br>
<small><small>407: Authentification proxy exig�e Le serveur proxy exige une authentification du client avant de transmettre la requ�te.
</small></small><br>
<small><small>408: Requ�te hors-d�lai Le client n'a pas pr�sent� une requ�te compl�te pendant le d�lai maximal qui lui �tait imparti, et le serveur a abandonn� la connexion.
</small></small><br>
<small><small>409: Conflit La requ�te entre en conflit avec une autre requ�te ou avec la configuration du serveur.
</small></small><br>
<small><small>410: Parti L'adresse (URI) demand�e n'existe plus et a �t� d�finitivement supprim�e du serveur.
</small></small><br>
<small><small>411: Longueur exig�e Le serveur a besoin de conna�tre la taille de cette requ�te pour pouvoir y r�pondre.
</small></small><br>
<small><small>412: Pr�condition �chou�e Les conditions sp�cifi�es dans la requ�te ne sont pas remplies.
</small></small><br>
<small><small>413: Corps de requ�te trop grand Le serveur ne peut traiter la requ�te car la taille de son contenu est trop importante.
</small></small><br>
<small><small>414: URI trop long Le serveur ne peut traiter la requ�te car la taille de l'objet (URI) a retourner est trop importante.
</small></small><br>
<small><small>415: Format non support� Le serveur ne peut traiter la requ�te car son contenu est �crit dans un format non support�.
</small></small><br>
<small><small>416: Plage demand�e invalide Le sous-ensemble de recherche sp�cifi� est invalide.
</small></small><br>
<small><small>417: Comportement erron� Le comportement pr�vu pour le serveur n'est pas support�.
</small></small><br>
<small><small>500: Erreur interne du serveur Le serveur HTTP a rencontr� une condition inattendue qui l'a emp�ch� de traiter la requ�te.
</small></small><br>
<small><small>501: Non mis en oeuvre Le serveur HTTP ne supporte pas la fonctionnalit� n�cessaire pour traiter la requ�te.
</small></small><br>
<small><small>502: Mauvais interm�diaire Le serveur interm�diaire a fourni une r�ponse invalide.
</small></small><br>
<small><small>503: Service indisponible Le serveur HTTP est actuellement incapable de traiter la requ�te en raison d'une surcharge temporaire ou d'une op�ration de maintenance.
</small></small><br>
<small><small>504: Interm�diaire hors-d�lai Cette r�ponse est identique au code 408 (requ�te hors-d�lai).
</small></small><br>
<small><small>505: Version HTTP non support�e La version du protocole HTTP utilis�e dans cette requ�te n'est pas (ou plus) support�e par le serveur.
</small></small><br>

</div>
</div>
{FOOTER}
</body>
</html>
