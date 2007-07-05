all: atftp-0.7/atftp

atftp-0.7/atftp:
	cd atftp-0.7 ;\
	./configure --disable-libreadline ;\
	make
	strip $@
	cp atftp-0.7/atftp atftp
