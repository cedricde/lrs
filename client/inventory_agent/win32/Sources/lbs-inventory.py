#!/usr/bin/env python


#
# ce script est un petit demon qui tranfert les fichier csv
# qu'il trouve dans le repertoire courant en question, via le programme
# envoie.py
#
# un fichier csv est un fichier qui se termine par... .csv, bien sur
import os, stat, time, ConfigParser, string
import urllib, md5, sys
import win32api, win32con, win32file # win32 calls
try:
    import win32security # win32 calls that doen't exists under win/16
except:
    pass
    
import re                                           # regexps
import envoi

# config file loading
def charge_config(fichier, config={}):
    """
    renvoie un dictionnaire avec des cles correspondant aux options.
    les sections ne sont pas prises en compte, car il y a trop peu
    d'options, pour necessiter un classement inutile.
    """

    # copy the array
    config = config.copy()
    # runs the parser
    cp = ConfigParser.ConfigParser()
    # parse the file
    cp.read(os.path.join(install_dir, fichier))
    # then loop over the sections
    for sec in cp.sections():
        name = string.lower(sec)
        for opt in cp.options(sec):
            config[ string.lower(opt)] = string.strip(cp.get(sec, opt))
    return config

# build a list of all files in "top" directory, ending with "extension"
def trouver_fichier(top,extension):
    """
    cette fonction parcourt recursivement les sous-repertoires de top
    a la recherche des fichiers qui se termine par l'extension.
    """
    res = []

    # get the dir list
    names = os.listdir(top)

    # then loop over
    for name in names:
       # tries go get stats about file "name"
        filename = os.path.join(top, name)
        try:
            st = os.lstat(filename)
        except os.error:
            logd.write('[' + time.ctime() + '] - ' + 'WARN - ' + "Can't stat [" + filename + "]\n")
            logd.flush()
            continue
        # go deeply if that's a dir
        if stat.S_ISDIR(st.st_mode):
            #logd.write('[' + time.ctime() + '] - ' + 'INFO - ' + "Parsing directory [" + filename + "]\n")
            res.extend(trouver_fichier(filename, extension))
        # and if that's a file
        elif stat.S_ISREG(st.st_mode):
        # tests its extension
            if name.endswith(extension):
                #logd.write('[' + time.ctime() + '] - ' + 'INFO - ' + "Found file [" + filename + "]\n")
                # and keep the file if it corresponds
                res.append(filename)
    # end game, returns the result
    return res

# default value for test (not used on prod.)
conf = { "serveur_apps" : 'http://lbs/transfert.php', }

# get the install directory
try:
    key = win32api.RegOpenKey(win32con.HKEY_CLASSES_ROOT, "Linbox\\lrs-inventory", 0, win32con.KEY_READ)
    install_dir = win32api.RegQueryValueEx(key, "Path")[0]
except win32api.error, (errno, strerror, test):
    install_dir = os.path.dirname(os.path.abspath(sys.argv[0]))
    log_file=os.path.join(install_dir, "lrs-inventory.log")
    logd = open(log_file, "a+")
    logd.write('[' + time.ctime() + '] - ' + "ERROR: " + strerror + ": " + test + "\n")
    logd.flush()
    print "ERROR: " + strerror + ": " + test + "\n"
    sys.exit()
key.Close()

# compute the logfile's path
log_file=os.path.join(install_dir, "lrs-inventory.log")

# open it, append mode
logd = open(log_file, "a+")

# and starts to log in:
logd.write('[' + time.ctime() + '] - ' + "START\n")
logd.flush()

# log the conf's file name
logd.write('[' + time.ctime() + '] - ' + 'INFO - ' + "Config File : [" + os.path.join(install_dir,"config.ini") + "]\n")
logd.flush()

# give out if the install dir is empty
if(install_dir == None):
    logd.write('[' + time.ctime() + '] - ' + 'ERROR - ' + "Install dir key not found (empty key ?)\n")
    logd.flush()
    os.sys.exit(1)    

# read the configuration
conf=charge_config('config.ini', conf)

# V2 or V3 ?
ocsver = 2
prog = os.path.join(install_dir, os.path.join('ocs', 'OCSInventoryCVS.exe'))
if not os.access(prog, os.X_OK):
    prog = os.path.join(install_dir, os.path.join('ocs', 'OCSInventory.exe'))
    ocsver = 3
    
# updates Apps.csv
if ocsver == 2:
    try :
        # get the server's mdsum
        md5_serv = urllib.urlopen( conf["serveur_apps"] + '?' +  urllib.urlencode({'md5_calc': 1,'fichier':  'Apps.csv'})).read()
        app_ocs = os.path.join(install_dir, os.path.join('ocs', 'Apps.csv'))
        m = md5.new()
        try: 
            ici = open(app_ocs,'r').read()
        except:
            logd.write('[' + time.ctime() + '] - ' + 'WARN - ' + "Can't open the database [" + app_ocs + "]\n")
            logd.flush()
            ici =" "
            
        m.update( ici )
        md5_ici = m.hexdigest()

        if (md5_ici != md5_serv):
            tab = conf["serveur_apps"].split('/')
            fichier = string.join( tab[:-1],'/' ) + '/Apps.csv'
            logd.write('[' + time.ctime() + '] - ' + 'INFO - ' + "Database fetch from [" + fichier + "]\n")
            logd.flush()
            open(app_ocs,'wb').write( urllib.urlopen(fichier).read())
        else:
            logd.write('[' + time.ctime() + '] - ' + 'INFO - ' + "NOT updating the database [" + app_ocs + "]\n")
            logd.flush()
    except:
        logd.write('[' + time.ctime() + '] - ' + 'WARN - ' + "Error while updating the database\n")
        logd.flush()


logd.write('[' + time.ctime() + '] - ' + 'INFO - ' + 'Running the inventory agent [' + prog + ']\n')
logd.flush()

# running the client ...
try:
    pid = os.spawnl(os.P_WAIT, prog, prog)
except OSError, (errno, strerror):
    logd.write('[' + time.ctime() + '] - ' + 'ERROR - ' + "Agent not launched (" + strerror + ")\n")
    logd.write('[' + time.ctime() + '] - ' + "END\n\n")
    logd.flush()
    sys.exit()

logd.write('[' + time.ctime() + '] - ' + 'INFO - ' + "Sending files\n")

# ... then send its results
os.chdir(install_dir)
liste =	trouver_fichier('ocs', '.csv')

# parses the file list, then send them
nbloop = 0

index = 0
found = 0
for name in liste:
    if re.compile('\\Network').search(name):
        found = 1
        break
    index += 1

if found:
    tmpval = liste [0]
    liste[0] = liste[index]
    liste[index] = tmpval

for i in liste:
    envoye= 1
    i = string.join(string.split(i, '\\'), '/')
    
    # don't send if not in a subdirectory (concerns Apps.csv and config.csv)
    if (len(i.split('/'))<3):
        envoye=0
        
    # tries to send 10 times
    while ( envoye != 0 ):
        envoye=envoi.envoi_main(i, conf['serveur_apps'],logd)
        time.sleep(1)

        # failure ?        
        if (envoye != 0):
            nbloop = nbloop + 1
            if(nbloop == 11):
                logd.write('[' + time.ctime() + '] - ' + 'ERROR - ' + "Sending has been canceled after 10 unsuccessful tries\n")
                logd.flush()
                os.sys.exit(1)
            logd.write('[' + time.ctime() + '] - ' + 'WARNING - ' + "Will rety to send result in 30 seconds\n")
            logd.flush()

            # sleep 30 seconds
            time.sleep(int(30))

# end game            
logd.write('[' + time.ctime() + '] - ' + "END\n\n")
logd.flush()
