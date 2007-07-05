ATFTP_DIR=./3rd_party/atftp/atftp-0.7

all: atftp


atftp:
	[ -d $(ATFTP_DIR) ]
	(cd $(ATFTP_DIR); ./configure --disable-libreadline; make;)
	cp $(ATFTP_DIR)/$@ .
	strip $@
