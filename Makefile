INKSCAPEDIR = /usr/share/inkscape/extensions/
DXF_OUTLINES = $(INKSCAPEDIR)/dxf_outlines.py
OPENSCAD = openscad --enable manifold

SCADFILES =                                             \
	ball-end.scad                                   \
	bedholder.scad                                  \
	cable-cover.scad                                \
	carriage.scad                                   \
	corner-bottom.scad                              \
	corner-top.scad                                 \
	eccentric-spacer.scad                           \
	effector.scad                                   \
	foot.scad                                       \
	groovemount.scad                                \
	idler-spacer.scad                               \
	magnetic-probe.scad                             \
	tslotnut.scad

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
