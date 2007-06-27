WOL_DIR=./wol

wol:
	(cd $(WOL_DIR); ./configure --enable-static; make CFLAGS=-O2 wol_LDFLAGS=--static; strip ./src/wol )

.PHONY: wol
