--
-- dynn.layers package. Holds definition and layout of the layers of neurons.
--
-- Copyright (C) 2018  <George Shapovalov> <gshapovalov@gmail.com>
--
-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU Lesser General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with this program.  If not, see <http://www.gnu.org/licenses/>.
--

with dynn.neurons;

generic
package dynn.layers is

    package PN is new dynn.neurons;

    -- Indices;
    -- Inputs/outputs, representative of "physical entiites"; use to catch "wrong index used" errors
    type    InputIndex_Base is new Natural;
    subtype InputIndex  is InputIndex_Base range 1 .. InputIndex_Base'Last;
    type    OutputIndex is new Positive;
    -- to track neurons associated with the layer.
    --  NOTE: this is *different* from NeuronIndex defined in dynn.nets
    type    NeuronIndex_Base is new Natural;
    subtype NeuronIndex is NeuronIndex_Base range 1 .. NeuronIndex_Base'Last;

    -- associated arrray types for holding params
    type Input_Connection_Array  is array (InputIndex range <>)  of ConnectionIndex;
    type Output_Connection_Array is array (OutputIndex range <>) of ConnectionIndex;
    type Neuron_Array is array (NeuronIndex range <>) of PN.NeuronClass_Access;


    -- representation record, to have common interface to pass data around
    type LayerRec(N : NeuronIndex) is record
        neurons : Neuron_Array(1 .. N);
        -- might get outputs or inputs here, so use generic neuronal array
        --weightMatrix : some matrix;
        -- these are stored in referenced neurons anyway
        -- however constructing a separate matrix may be useful if we need to pass it to, e.g. e GPU
        -- but will worry about this when (or if) I ever get there..
        --deltas? : likely need to store those too
    end record;
    type LayerRecPtr is access LayerRec;

    ----------------------------------------------
    -- Layer interface
    -- As with NNet itself, multiple representations are possible
    -- so we make it an Interface with common functionality,
    -- leaving the representations details to children.
    -- (also to defer the representation choice, as I am not sure ATM what would work better)
    --
    -- At the bare level, Layer can be a simple list of neurons, with propagation done
    -- in a simple loop (possibly parallelizable) per-neuron.
    -- More advanced propagators use vectors of values and weight matrices,
    -- to try to parallelize this via mpi or GPU use..
    -- To tie it all together an OOP paradigm is used, as the most natural representation.
    -- The base type, called below Layer_Interface, provides only basic interface and functionality,
    -- with Matrix_Layer_Interface and others overriding it to provide more elaborate propagators.
    -- (with the notion that their derived types would hold additional data, thus they would expose
    -- additional primitives too).
    --
    -- NOTE: layer type should be set at net creation type, as different layr types in hierarchy
    -- would have different (extra) data. Thus it would be impossible anyway to run an optimized
    -- (e.g. Matrix) prop on a net constructed from basic layers..
    -- The other way around can be possible, but does not make much sense. But if it is
    -- really desired, use of basic (inherited) propagator can be forced in a usual OOP way
    -- (by performing a type view conversion).
    --
    -- Also, to provide a common interface for propagator calls, and since Ada does not support
    -- overridable interface primitives (only class-wide methods of interfaces can contain code),
    -- Layer_Interface has to be an (abstract) type. Keeping it an interface might provide more
    -- flexibility but will duplicate the ADT code (we would have to mirror each interface
    -- first with abstract type and then derive specific types holding data from that).

    type Layer_Interface is abstract tagged private; -- we need redispatching on some methods
    type LayerClass_Access is access Layer_Interface'Class;

    type Layer_Reference (Data : not null access Layer_Interface'Class) is private
        with Implicit_Dereference => Data;

    type Layer_Generator is access function return Layer_Interface'Class;

    -- primitives
    function  ToRec  (LI : Layer_Interface) return LayerRec is abstract;
    procedure FromRec(LI : in out Layer_Interface; LR : LayerRec) is abstract;
    --     procedure Clear  (LI : in out Layer_Interface) is abstract;
    --
    function  NNeurons(LI : Layer_Interface) return NeuronIndex_Base is abstract;
    --     procedure Add_Neuron(LI : in out Layer_Interface; neur : PN.NeuronClass_Access) is abstract;
    --     procedure Del_Neuron(LI : in out Layer_Interface; idx : NeuronIndex) is abstract;
    function  Neuron(LI : Layer_Interface; idx : NeuronIndex) return PN.NeuronClass_Access is abstract;
    function  Neuron(LI : Layer_Interface; idx : NNet_NeuronId) return PN.NeuronClass_Access is abstract;
    --     procedure Reset_Neuron(LI : Layer_Interface; idx : NeuronIndex; np : PN.Neuron_Access) is abstract;

    procedure Add_Neuron(LI : in out Layer_Interface; Nidx : NNet_NeuronId) is abstract;
    -- adds neuron to layer by index. Ignores duplicates (so that each neuron is added only once)
    -- NOTE: layers are supposed to only hold neurons, no outputs, so enforcing proper idx type.
    --  prop logic needsrethuinking here - what happens with pass-through connections?


    --------------
    -- propagators
    -- As we go with the abstract type instead of interface here, no need for
    -- class-wide methods to keep actual code and glue primitives.
    --
    --  stateless propagation, no side effects
    function  Prop_Forward(L : Layer_Interface; inputs : NNN.State_Vector) return NNN.State_Vector;
    function  Prop_Forward(L : Layer_Interface; inputs : NNN.Checked_State_Vector) return NNN.Checked_State_Vector;
    --
    -- these (procedural form) should be much more efficient, as the State_Vector is modified directly
    -- instead of being recreated all the time..
    procedure Prop_Forward(L : Layer_Interface; SV : in out NNN.State_Vector);
    procedure Prop_Forward(L : Layer_Interface; SV : in out NNN.Checked_State_Vector);

    -- stateful propagation, only makes sense for some cases.
    --     procedure SetInputs(L : in out Layer_Interface'Class; inputs : ValueArray);
    procedure Prop_Forward(L : Layer_Interface);
    -- NOTE: layers only keep references to neurons, which in turn keep weights and do calcs
    -- no need for "in out"" here. In fact we need in-only parameter here to allow pass-by-reference optimization


    ---------------------------------------------
    -- Layer with linear algebra (wLA) - provides additional optimization capability
    type Matrix_Layer_Interface   is abstract new Layer_Interface with private;
    type Matrix_LayerClass_Access is access Matrix_Layer_Interface'Class;

    --  stateless propagation, no side effects
    function  Prop_Forward(L : Matrix_Layer_Interface; inputs : NNN.State_Vector) return NNN.State_Vector;
    function  Prop_Forward(L : Matrix_Layer_Interface; inputs : NNN.Checked_State_Vector) return NNN.Checked_State_Vector;

    -- stateful propagation, only makes sense for some cases.
    procedure Prop_Forward_Basic(L : Matrix_Layer_Interface);

private

    type Layer_Interface is abstract tagged null record;

    type Layer_Reference (Data : not null access Layer_Interface'Class) is null record;


    type Matrix_Layer_Interface is abstract new Layer_Interface with null record;

end dynn.layers;
