INKSCAPEDIR = /usr/share/inkscape/extensions/
DXF_OUTLINES = $(INKSCAPEDIR)/dxf_outlines.py
OPENSCAD = openscad --enable manifold

SCADFILES =					\
	bedholder.scad				\
	ball-end.scad				\
	effector.scad				\
	bottom-corner.scad			\
	carriage.scad				\
	crowned-idler.scad			\
	eccentric-spacer.scad			\
	foot.scad				\
	idler-spacer.scad			\
	joint.scad				\
	top-corner.scad				\
	tslotnut.scad				\
	groovemount.scad			\
	retractable.scad			\
	cable-cover.scad

STLFILES = $(SCADFILES:.scad=.stl)
DEPFILES = $(addsuffix deps,$(SCADFILES))

all: $(STLFILES)

%.dxf: %.svg
	$(DXF_OUTLINES) --units='25.4/90' --encoding=latin1 $< > $@

%.stl: %.scad
	$(OPENSCAD) -d $<deps -m $(MAKE) -o $@ $<

assembly/groovemount-assembly.stl: groovemount.scad
	$(OPENSCAD) -Dmode='"preview"' -d $<deps -m $(MAKE) -o $@ $<

clean:
	rm $(STLFILES) $(DEPFILES)

-include $(DEPFILES)
