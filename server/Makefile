WOL_DIR=./3rd_party/wol/wol-0.7.1

wol:
	(cd $(WOL_DIR); ./configure --enable-static; make CFLAGS=-O2 wol_LDFLAGS=--static;)
	cp $(WOL_DIR)/src/wol .
	strip ./wol

.PHONY: wol
