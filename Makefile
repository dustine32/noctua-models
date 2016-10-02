OBO= http://purl.obolibrary.org/obo
GO=../go/ontology
GOX=$(GO)/extensions

# default catalog
CAT=catalog-v001.xml

# fake catalog that rewires go-lego to null
FAKECAT=fake-catalog.xml

# catalog that rewires go-lego to local cache
MIRROR = mirror-catalog.xml

# catalog that rewires go-lego to extracted minimal module
MODCAT = module-catalog.xml

all: noctua-models.owl noctua-models-merged.owl noctua-models-noimport.owl
test: all
clean:
	rm -rf $(MIRROR)

# ----------------------------------------
# COMBINED MODELS
# ----------------------------------------

# combined models, preserve full imports
# reasoning: complete
noctua-models.owl: $(MIRROR)
	owltools --catalog-xml $(MIRROR) models/[0-9]* --merge-support-ontologies --set-ontology-id http://model.geneontology.org/noctua-models.owl -o -f ttl $@

# combined models, import module merged
# reasoning: complete
noctua-models-merged.owl: noctua-models.owl target/go-lego-module.owl
	owltools --catalog-xml $(MODCAT) $< --merge-imports-closure -o $@

# combined models, no imports, no merged modules
# reasoning: incomplete
noctua-models-noimport.owl: noctua-models.owl
	owltools --catalog-xml $(FAKECAT) $< --remove-imports-declarations -o $@

# test: add labels to all abox members
noctua-models-labeled.owl: target/go-lego-module.owl
	owltools --catalog-xml catalog-v001.xml $< --label-abox -o -f ttl $@

# combined models, converted to obographs
noctua-models.json: noctua-models.owl
	minerva-cli.sh --catalog-xml $(FAKECAT) --owl-lego-to-json  -i $< --pretty-json -o $@ 

# combined models, no imports, turtle
# (this is an intermediate target)
target/m.owl-ttl:
	owltools --catalog-xml $(FAKECAT) models/* --merge-support-ontologies --remove-imports-declarations -o -f ttl $@

# as above, roundtripped
target/m.ttl: target/m.owl-ttl
	riot $< > $@

# ----------------------------------------
# MODULES
# ----------------------------------------

# create a complete module
target/go-lego-module.owl: $(MIRROR)
	owltools --catalog-xml $(MIRROR) models/* --merge-support-ontologies --extract-module -c -s $(OBO)/go/extensions/go-lego.owl -o $@


# use owltools slurp-import-chain to mirror all imports
$(MIRROR):
	owltools $(OBO)/go/extensions/go-lego.owl --sic -d . -c $@

# ----------------------------------------
# PER-MODEL FILES
# ----------------------------------------

# direct ttl translation, no imports
target/%.ttl: models/%
	owltools --catalog-xml $(FAKECAT) $< --remove-imports-declarations -o -f ttl $@

# a module for an individual model
# (intermediate target, see next step)
target/%-module.owl: models/% $(MIRROR)
	owltools --catalog-xml $(MIRROR) $< --merge-support-ontologies --extract-module -n $(OBO)/go/noctua/$@ -c -s $(OBO)/go/extensions/go-lego.owl -o $@
.PRECIOUS: target/%-module.owl

# a model merged with its module
target/%-plus-module.owl: models/% target/%-module.owl
	owltools --catalog-xml $(FAKECAT) $^ --merge-support-ontologies  --remove-imports-declarations -o  $@

target/%.json: models/%
	owltools --catalog-xml $(FAKECAT) $< --remove-imports-declarations -o -f json $@

%.obo: %.owl
	owltools --catalog-xml $(FAKECAT) $< --set-ontology-id $(OBO)/test/$@ -o -f obo --no-check $@

%.json: %.owl
	owltools --catalog-xml $(FAKECAT) $<  -o -f json  $@
