obj-m = xt_FULLCONENAT.o
CFLAGS_xt_nat_open.o := ${CFLAGS}

IPT_LIB = libipt_FULLCONENAT.so
CCFLAGS ?= -Wall -shared -fPIC -D_INIT=libipt_FULLCONENAT_init

KVERSION = $(shell uname -r)
all:
	$(CC) $(CCFLAGS) -o $(IPT_LIB) libipt_FULLCONENAT.c
	make -C /lib/modules/$(KVERSION)/build M=$(PWD) modules
clean:
	rm -rf $(IPT_LIB)
	make -C /lib/modules/$(KVERSION)/build M=$(PWD) clean

git:
	@git add  -A
	@git commit -m "update by liming" -a
	@git tag -sf release -m 'change tag'
	@git push
	@git push --tags -f
