a = Analysis([os.path.join(HOMEPATH,'support\\_mountzlib.py'), os.path.join(HOMEPATH,'support\\useUnicode.py'), 'Sources\\lbs-inventory.py', 'Sources\\envoi.py'],
             pathex=['D:\\InventoryAgent'])
pyz = PYZ(a.pure)
exe = EXE( pyz,
          a.scripts,
          a.binaries,
          name='lbs-inventory.exe',
          debug=0,
          strip=0,
          upx=0,
          console=0 , icon='Medias\\logo-icon.ico')
