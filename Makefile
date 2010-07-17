prefix = /usr/local
datadir = $(prefix)/share/dewi

bin_make = make
bin_perl = perl
bin_sh = /bin/sh

local_stamp = local.stamp

all:
	@$(bin_sh) ./generate.sh sh="$(bin_sh)" perl="$(bin_perl)" make="$(bin_make)" here
	@touch $(local_stamp)

sys:
	@$(bin_sh) ./generate.sh sh="$(bin_sh)" perl="$(bin_perl)" make="$(bin_make)" data=$(datadir) sys
	@rm -f $(local_stamp)

install:
	@[ ! -e "$(local_stamp)" ] || (printf 'Do not call "install" in non-sys builds.\n'; exit 1;)
	@$(bin_sh) ./install.sh all-but-doc

doc:
	@(cd doc && $(MAKE))

install-doc:
	@$(bin_sh) ./install.sh doc

.PHONY: all doc install install-doc sys
