SCADFILES = \
	tslotnut.scad

all: $(SCADFILES:.scad=.stl)

%.stl: %.scad
	openscad -o $@ $<
