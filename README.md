# noctua-models

This is the data repository for the models created and edited with the Noctua tool stack for GO. See https://github.com/geneontology/noctua
for details on the Noctua tool.

The models are stored as OWL in the [models/](models/) directory.

## OWL Modeling

See also the documentation here:
https://github.com/geneontology/minerva/blob/master/specs/owl-model.md

The native form of a Noctua model is OWL. A Noctua model consists of *ABox* axioms (ie axioms about individuals) - this is in contrast to a traditional ontology which is *TBox* axioms (ie class axioms). We use the term 'LEGO model' when we are talking about an ABox with members that instantiate GO molecular function classes (ie an activity flow diagram). More generally 'Noctua model' for when we have minimal assumptions about ontologies used.

## General modeling paradigm (informal)

The general paradigm can be summarized as: create an individual for anything, 'define' that individual by its connections. The individuals generally do not have properties such as labels attached. Individuals are generated by the tool and are assumed to be 'identity-less' and unique to the model (with the exception being some of the supporting provenance type individuals, e.g. an instance of a publication).

To state that gene product `Shh` has some unspecified activity whilst localized to the nucleus, we would create:

```
:001 rdf:type Shh
:002 rdf:type MF:root
:003 rdf:type CC:nucleus

:002 RO:enabled_by :001
:002 BFO:occurs_in :003
```

Note that we are modeling specific gene products like 'Shh protein' as classes


In the Noctua display, this would be visualized as a single box with no connectors. The box would correspond to `001` and would be labeled with the root class from MF (`molecular_function`). The information about the relationship to `002` and `003` would be compacted in to the MF box, like this:

```
   +-------------------+
   | molecular function|
   +-------------------+
   | enabled by(Shh)   |
   | occurs_in(nucleus)|
   +-------------------+
```



See other lego docs for full details on relations. 

## Evidence and provenance

All evidence is stored on a per-axiom basis. We create an axiom annotation, that uses a *WILL CHANGE* AnnotationProperty to connect the axiom to the evidence instance IRI (it's necessary for this to be to the IRI not individual because owls). The evidence instance IRI should be for an individual that instantiates an ECO class. From this, other OPEs hang off - publication, supporting object (may be literals but this will change *TODO* add ticket here)

Provenance can be at the level of axiom, individual or ontology. The APs are dc:date and dc:contributor are added automatically so you should see a lot of these on new models.

## Availability

Currently stored here:
https://github.com/geneontology/noctua-models

Any existing set of GO associations can be converted, albeit in a 'degenerate' disconnected form. This can still be useful for the purposes of uniform tooling and programmatic access:

    owltools go.owl --gaf my.gaf --gaf-lego-indivduals -o my-lego.owl
    
See this ticket for more details: https://github.com/owlcollab/owltools/issues/117

## Down in the weeds background details

 * Switching to all-individual model: #76 -- this is now done but we may have vestiges of documentation that assume the class expression model. In particular, the lego protege plugin only works with the class expression model
