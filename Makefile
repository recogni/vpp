
all: foo.v

%.v: %.vp
	./vpp.pl -perl $< -output $@

