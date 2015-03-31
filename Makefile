SCADFILES = \
	tslotnut.scad \
	corner.scad

all: $(SCADFILES:.scad=.stl)

%.stl: %.scad
	openscad -o $@ $<
