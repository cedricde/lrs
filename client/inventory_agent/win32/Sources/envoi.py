#!/usr/bin/env python

# (was ! /usr/bin/python)

import httplib, mimetypes, sys, md5, binascii, os, re
import urllib
import time

# if defined show debug information
debug = 0
 
class envoi:
	
	_url=""
	
	_cgi=""
	
	# l'objet de type httplib
	_h=""
	

	def __init__(self,url):
		self._url=url
		self.extract_cgi()
	
	def extract_cgi(self):
		"""
		recupere le cgi, le fichier demandé, sans le debut, ni les
		parametres.	
		"""
		r = re.compile('^[^/]*://[^/]*/')
		self._cgi = r.sub('',self._url)

	def open_http_connection(self):
		# connection creation
		self._host=self._url.split('/')[2]

		# get the transposrt, depending on the source URL
		if self._url.startswith('http:'):
			self._h = httplib.HTTP(self._host)
		elif self._url.startswith('https:'):
			self._h = httplib.HTTPS(self._host)


	def post_multipart(self,fields, files):
		"""
		Post fields and files to an http host as multipart/form-data.
		fields is a sequence of (name, value) elements for regular form fields.
		files is a sequence of (name, filename, value) elements for data to be uploaded as files
		Return the server's response page.
		"""
		# encodage du fichier en multipart
		try:
			content_type, body = self.encode_multipart_formdata(fields, files)

			self.open_http_connection()
			# creation de la requete post 	
			self._h.putrequest('POST','/' + self._cgi )
			self._h.putheader('content-type', content_type)
			self._h.putheader('content-length', str(len(body)))
			self._h.putheader('host',self._host)
			self._h.endheaders()
			self._h.send(body)

			# envoie de la requete.
			errcode, errmsg, headers = self._h.getreply()

			# lecture de la reponse du serveur
			return self._h.file.read()
		except:
			return 'erreur, ne peut pas contacter le serveur'

	def encode_multipart_formdata(self,fields, files):
		"""
		fields is a sequence of (name, value) elements for regular form fields.
		files is a sequence of (name, filename, value) elements for data to be uploaded as files
		Return (content_type, body) ready for httplib.HTTP instance
		"""
		BOUNDARY = '----------ThIs_Is_tHe_bouNdaRY_$'
		CRLF = '\r\n'
		L = []
		# construction du corps de la requete, qui doit avoir cette forme
		#   ---------separateur----------------
		#   Content-Disposition: form-data; name="cle"
		#
		#   	valeur
		#   ---------separateur----------------
		#   Content-Disposition: form-data; name="cle"
		#
		#   valeur
		#   ---------separateur----------------
		#   Content-Disposition: form-data; name="cle"; filename="nomfichier"
		#   Content-Type: text/type
		#
		#   contenu_du_fichier
		#   ---------separateur------------------
		#   
		# le dernier est plus long de 2 --
		for (key, value) in fields:
			L.append('--' + BOUNDARY)
			L.append('Content-Disposition: form-data; name="%s"' % key)
			L.append('')
			L.append(value)
		for (key, filename, value) in files:
			L.append('--' + BOUNDARY)
			L.append('Content-Disposition: form-data; name="%s"; filename="%s"' % (key, filename))
			L.append('Content-Type: %s' % self.get_content_type(filename))
			L.append('')
			L.append(value)
		L.append('--' + BOUNDARY + '--')
		L.append('')
		body = CRLF.join(L)
		content_type = 'multipart/form-data; boundary=%s' % BOUNDARY
		return content_type, body

	def get_content_type(self,filename):
		"""
		essaie de deviner le type mime a partir de son extension.
		"""
		# could be improved to work like file, with magics numbers.
		return mimetypes.guess_type(filename)[0] or 'application/octet-stream'


	def get_md5_fichier(self,fichier,path):
		"""
		recupere la somme md5 du fichier sur le serveur
		"""
		self.open_http_connection()
		self._h.putrequest('GET','/' + self._cgi +'?' + urllib.urlencode({'md5_calc': 1,'fichier':  path}))
		self._h.putheader('host',self._host)
		self._h.endheaders()
		#TODO tester le code de retour
		self._h.getreply()
		return self._h.file.read()

def envoi_main(path, server, logd):		


	# on lit le fichier, et el mplace avec son nom dans le tableu fichier
	# FEINTE : la virgule du fond permet de distinguer une liste d'un element.
	
	donnee = open(path).read()

	fichier = ('filename',path,donnee),

	# le calcul de la somme md5 est réalisé par l'appel md5.digest
	m = md5.new()
	m.update(donnee)
	# FEINTE : la virgule du fond permet de distinguer une liste d'un element.
	somme_client = m.hexdigest()
	param = ('md5',somme_client),('fullpath',path),

	e = envoi(server)
	# on verifie d'abord si le tranfert est utile
	#
	try:
		somme_serveur = e.get_md5_fichier(fichier,path)
	except:
		logd.write('[' + time.ctime() + '] - ' + 'WARNING - ' + "MD5 not found for [" + path + "]\n")
		return 1

	if  (somme_serveur == somme_client):
		logd.write('[' + time.ctime() + '] - ' + 'INFO - ' + "[%s] hasn't changed\n" % path)
		logd.flush()

	#si le fichier est vide, on tranfert rien
	elif (len(donnee) == 0):
		logd.write('[' + time.ctime() + '] - ' + 'INFO - ' + "[%s] empty\n" % path)
		logd.flush()
	else:	
		logd.write('[' + time.ctime() + '] - ' + 'INFO - ' + "[%s] sent\n" % path)
		logd.flush()

		if ( debug == 1 ):
			logd.write("-----------======== BEGIN client Side : envoi.py =========>>>>>>>>>>>>>>>\n")
			logd.write("valeur de variable 'param' : \n")
			logd.write(param+"\n")
			logd.write("\n")
			logd.write("valeur de variable 'fichier' : \n")
			logd.write(fichier+"\n")
			logd.write("<<<<<<<<<<<======== END client Side : envoi.py =========-----------------\n")
		
		res= e.post_multipart(param ,fichier)
		if res.startswith('ok'):
			logd.write('[' + time.ctime() + '] - ' + 'INFO - ' + "[%s] successfully transfered\n" % path)
			logd.flush()
		else:
			logd.write('[' + time.ctime() + '] - ' + 'INFO - ' + "[%s] successfully transfered (" % path + res +")\n")
			logd.flush()
			return 1
	return 0
