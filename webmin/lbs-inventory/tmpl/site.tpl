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
La requête HTTP a été traitée avec succès.
</small></small><br>
<small><small>201: Créé:
 La requête a été correctement traitée et a résulté en la création d'une nouvelle ressource.
</small></small><br>
<small><small>202: Accepté:
La requête a été acceptée pour être traitée, mais son traitement peut ne pas avoir abouti.
</small></small><br>
<small><small>203: Information non certifiée:
 L'information retournée n'a pas été générée par le serveur HTTP mais par une autre source non authentifiée.
</small></small><br>
<small><small>204: Pas de contenu:
 Le serveur HTTP a correctement traité la requête mais il n'y a pas d'information à envoyer en retour.
</small></small><br>
<small><small>205: Contenu réinitialisé: Le client doit remettre à zéro le formulaire utilisé dans cette transaction.
</small></small><br>
<small><small>206: Contenu partiel: Le serveur retourne une partie seulement de la taille demandée.
</small></small><br>
<small><small>300: Choix multiples: L'URI demandée concerne plus d'une ressource.
</small></small><br>
<small><small>301: Changement d'adresse définitif: La ressource demandée possède une nouvelle adresse (URI).
</small></small><br>
<small><small>302: Changement d'adresse temporaire: La ressource demandée réside temporairement à une adresse (URI) différente.
</small></small><br>
<small><small>303: Voir ailleurs: L'URI spécifié est disponible à un autre URI et doit être demandé par un GET.
</small></small><br>
<small><small>304: Non modifié: Le navigateur web a effectué une requête GET conditionnelle et l'accès est autorisé, mais le document n'a pas été modifié.
</small></small><br>
<small><small>305: Utiliser le proxy: L'URI spécifié doit être accédé en passant par le proxy.
</small></small><br>
<small><small>400: Mauvaise requête La requête HTTP n'a pas pu être comprise par le serveur en raison d'une syntaxe erronée.
</small></small><br>
<small><small>401: Non autorisé La requête nécessite une identification de l'utilisateur.
</small></small><br>
<small><small>403: Interdit Le serveur HTTP a compris la requête, mais refuse de la traiter.
</small></small><br>
<small><small>404: Non trouvé Le serveur n'a rien trouvé qui corresponde à l'adresse (URI) demandée.
</small></small><br>
<small><small>405: Méthode non autorisée Ce code indique que la méthode utilisée par le client n'est pas supportée pour cet URI.
</small></small><br>
<small><small>406: Aucun disponible L'adresse (URI) spécifiée existe, mais pas dans le format préféré du client.
</small></small><br>
<small><small>407: Authentification proxy exigée Le serveur proxy exige une authentification du client avant de transmettre la requête.
</small></small><br>
<small><small>408: Requête hors-délai Le client n'a pas présenté une requête complète pendant le délai maximal qui lui était imparti, et le serveur a abandonné la connexion.
</small></small><br>
<small><small>409: Conflit La requête entre en conflit avec une autre requête ou avec la configuration du serveur.
</small></small><br>
<small><small>410: Parti L'adresse (URI) demandée n'existe plus et a été définitivement supprimée du serveur.
</small></small><br>
<small><small>411: Longueur exigée Le serveur a besoin de connaître la taille de cette requête pour pouvoir y répondre.
</small></small><br>
<small><small>412: Précondition échouée Les conditions spécifiées dans la requête ne sont pas remplies.
</small></small><br>
<small><small>413: Corps de requête trop grand Le serveur ne peut traiter la requête car la taille de son contenu est trop importante.
</small></small><br>
<small><small>414: URI trop long Le serveur ne peut traiter la requête car la taille de l'objet (URI) a retourner est trop importante.
</small></small><br>
<small><small>415: Format non supporté Le serveur ne peut traiter la requête car son contenu est écrit dans un format non supporté.
</small></small><br>
<small><small>416: Plage demandée invalide Le sous-ensemble de recherche spécifié est invalide.
</small></small><br>
<small><small>417: Comportement erroné Le comportement prévu pour le serveur n'est pas supporté.
</small></small><br>
<small><small>500: Erreur interne du serveur Le serveur HTTP a rencontré une condition inattendue qui l'a empêché de traiter la requête.
</small></small><br>
<small><small>501: Non mis en oeuvre Le serveur HTTP ne supporte pas la fonctionnalité nécessaire pour traiter la requête.
</small></small><br>
<small><small>502: Mauvais intermédiaire Le serveur intermédiaire a fourni une réponse invalide.
</small></small><br>
<small><small>503: Service indisponible Le serveur HTTP est actuellement incapable de traiter la requête en raison d'une surcharge temporaire ou d'une opération de maintenance.
</small></small><br>
<small><small>504: Intermédiaire hors-délai Cette réponse est identique au code 408 (requête hors-délai).
</small></small><br>
<small><small>505: Version HTTP non supportée La version du protocole HTTP utilisée dans cette requête n'est pas (ou plus) supportée par le serveur.
</small></small><br>

</div>
</div>
{FOOTER}
</body>
</html>
