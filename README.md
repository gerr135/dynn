# dynn - Dynamic Neural Networks
This project provides a basic framework for dynamic ("mutable") neural networks, that can be represented (and thus stored/loaded) in a linear string (sequence encoding) and, thus can be coupled easily with genetic algorythms - mutated and evolved.

## Rationale
Most neural net (NNet) libraries focus on efficient representation of fixed neural networks, that are laid out in advance. This project tries to approach nnets from the "opposite" perspective - to follow the "natural" neural net (i.e. biological construct, at least its dynamic/evolution aspects) as much as possible. Neurons are allowed to make arbitrary connections within NNet, as well as to reconnect, be born (insertion of new ones) or die (removal of disconnected ones).

To make calculations (forward/back-props) more efficient, neurons are organized into layers, that allows to apply the usual set of parallelization features. However, unlike most other libs, that deal with pre-designed networks, neurons are organized into layers automatically here. A set of layer-forming algorithms is provided, that allows to sort unordered NNet or rearrange existing layers after mutation.

Each NNet can also be treated as a "black box" and be part of a bigger structure, coupling multiple NNets together - a-la different brain regions. Each NNet can be "encoded" via a linear string, providing for easy storage. In addition, aving linear encoding enables easy application of genetic algorithms - mimickicking adaptation of biological neural tissues to new stimulae. The ultimate goal is to use this lib for building a dynamic brain mapping that can evolve and self-construct to efficiently address a given task category. The library itself, however, is only a low-level framework that could be used to experiment with such design.

## Technicalities
The lib is structured as an ADT (abstract data type(s)) at the top level, with (eventually) multiple implementations of specific representations of these ADTs. Heavy use of Ada paradigm and features is emplyed throughout to make this in a sane way.

The project is a spiritual successor of the [wann project](https://github.com/gerr135/wann), that served, essentially, as an initial playground and allowed to test some design ideas. Main design difference from wann is the use of "dynamic indexing" of the NNet elements (neurons, entries, layers, etc) via dynamic handles, rather than a fixed countable index. While easy to relate to and implement efficiantly for fixed NNets, use of such index leads to heavy inefficiencies (due to the need of reindexing) when the NNet is mutated (specifically, during deletions). Thus, after establishing a general outlibe of the lib structure, but having faced major design oversight, it was clear that a more efficient implementation can be achieved with code refactored around a new design in this separate project.

 The new "handles" still take the form of integer indices, for ease of passing around and hand-crafting the (initial) NNets, and to have a uniform interface independent of implementation. However, unlike the "real" integer index, there is no requirement of continuity. Thus, e.g. direct for-loops over integer index values are not supported! Use the iterators instead (that support a streamlined interface similar to foreach of other languages, since Ada 2015..).

 This library strives to provide a single, unified handling interfacem via the ADTs mentioned above. Specific implementations are possible and (eventually) provided:
 
 | Name | Features | Design  | Intended use |
 | ---- | -------- | ------- | ------------ |
 | fixed   | immutable; efficient iteration and direct access | use basic Ada arrays, a-la Strings.Fixed. | final, "evolved" NNet. |
 | bounded | mutable, limited size; efficient iter&access | Use basic arrays, similar to Strings.Bounded | final NNets, limited evolution |
 | vectors | mutable; efficient direct access and iteration, inefficient additions, very inefficient deletions | use Ada.Container.Vectors | primarily use with some evolution |
 | lists   | mutable; inefficient iter&access, efficient additions/deletions | use linked lists | some use with focus on evolution |

### Basic structure overview
NNet consists of inputs, outputs and neurons organized into automatically created layers. Layers only hold neurons (no dumb neurons/connectrons used here - everything follows its function, to keep things logical and sane and keep code readable even after years of hiatus).

### Layout
NNet consists of [inputs,neurons,outputs; layers].
- input:  1-to-N connection, each is connected to multiple neurons
- neuron: N-to-N connection. Multiple outputs, single output value shared with multiple other inputs
- output: 1-to-1. Takes input from a single neuron.
    To mix inputs we need an active entity, which is essentially a neuron anyway. So Outputs are
    purely a service buffer in NNet.

- layers: do not hold extra stuff or do not pass extra info. They are there to organize neurons.
    Created automatically by sort methods or autoupdated if autosort is set.


