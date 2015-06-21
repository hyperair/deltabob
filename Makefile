INKSCAPEDIR = /usr/share/inkscape/extensions/
DXF_OUTLINES = $(INKSCAPEDIR)/dxf_outlines.py
OPENSCAD = openscad

SCADFILES =					\
	bedholder.scad				\
	bottom-corner.scad			\
	carriage.scad				\
	crowned-idler.scad			\
	eccentric-spacer.scad			\
	foot.scad				\
	idler-spacer.scad			\
	jaws.scad				\
	joint.scad				\
	top-corner.scad				\
	tslotnut.scad				\
	groovemount-top.scad			\
	groovemount-bottom.scad			\
	retractable.scad

STLFILES = $(SCADFILES:.scad=.stl)
DEPFILES = $(addsuffix deps,$(SCADFILES))

all: $(STLFILES)

%.dxf: %.svg
	$(DXF_OUTLINES) --units='25.4/90' --encoding=latin1 $< > $@

%.stl: %.scad
	$(OPENSCAD) -d $<deps -m $(MAKE) -o $@ $<

clean:
	rm $(STLFILES) $(DEPFILES)

-include $(DEPFILES)
