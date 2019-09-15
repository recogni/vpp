
example: example/foo.v

%.v: %.vp
	./vpp.pl +incdir+`pwd`/example -perl $< -output $@

