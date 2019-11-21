--
-- dynn.neurons package. Holds definition and layout of the neuron interface.
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

with Ada.Text_IO;

with Lists;
-- with connectors;

generic
package dynn.neurons is

    -------------------------------------
    --  Local input/output indices
    --
    -- For easy construction of neurons in descriptive parts, we provide an input index.
    -- Then, new neuron can be constructed as simply as:
    --   neur : Neuron := Create(activation  => Sigmoid,
    --                           connections => ((I,+1),(I,+2)), ...);
    --
    -- On outputs: normally neuron has a single outut, but multiple other entities can
    -- be connected to that (single) output.
    -- So, we provide OutputIndex here to track who takes signals from our neuron..
    --
    type    InputIndex_Base is new Natural;
    subtype InputIndex  is InputIndex_Base  range 1 .. InputIndex_Base'Last;
    type    OutputIndex_Base is new Natural;
    subtype OutputIndex is OutputIndex_Base range 1 .. OutputIndex_Base'Last;

    -- associated arrray types for holding params
    type Input_Connection_Array  is array (InputIndex  range <>) of Connection_Index;
    type Output_Connection_Array is array (OutputIndex range <>) of Connection_Index;
    type Weight_Array  is array (InputIndex_Base range <>) of Real;
    type Value_Array   is array (InputIndex range <>) of Real;
--     -- this one is not very useful, as it should be the state of the entire NNet that is propagated.
--     -- This can be done on per-neuron basis (albeit much less efficiently than per-layer),
--     -- but that would use the NNet value arrays, as defined in nnet_types.ads
--     -- Keeping these local types commented for now. To be removed later.

    -- vector-like lists of inputs/outputs (indexable and iterable)
    package IL is new Lists(Index_Base=>InputIndex_Base,  Element_Type=>Connection_Index);
    package OL is new Lists(Index_Base=>OutputIndex_Base, Element_Type=>Connection_Index);
    package WL is new Lists(Index_Base=>InputIndex_Base,  Element_Type=>Real);

    type Input_Reference_Type (Data : not null access IL.List_Interface'Class) is null record
        with Implicit_Dereference => Data;


    ----------------------------------------------
    -- Neuron interface: to be used by layers and nets
    -- Multiple representations are possible, defined in child packages.
    --
    -- like Input_Interface, is based on Connector_Interface, as output handling code is the same
--     package PCN is new Connectors(Index_Base      => OutputIndex_Base,
--                                   Connection_Type => Connection_Index,
--                                   No_Connection   => No_Connection );

--     type Neuron_Interface is interface and PCN.Connector_Interface;
    type Neuron_Interface is interface;
    type NeuronClass_Access is access all Neuron_Interface'Class;
    -- and the accessor
    type Neuron_Reference (Data : not null access Neuron_Interface'Class) is private
        with Implicit_Dereference => Data;

    -- primitives
    function Id (neur : Neuron_Interface) return NeuronId  is abstract;

    function Inputs  (neur : Neuron_Interface) return Input_Reference_Type is abstract;
    function Outputs (neur : Neuron_Interface) return OL.List_Interface'Class is abstract;
    function Weights (neur : Neuron_Interface) return WL.List_Interface'Class is abstract;


    --------------------------------------------
    -- Utility (class-wide)
    procedure Print_Structure(neur : Neuron_Interface'Class;
                              F : Ada.Text_IO.File_Type := Ada.Text_IO.Standard_Output);

    function Prop_Forward (neur : Neuron_Interface'Class; data  : Value_Array) return Real;

private

    type Neuron_Reference (Data : not null access Neuron_Interface'Class) is null record;

--     package WV is new Lists(Index_Base=>InputIndex_Base,  Element_Type=>Real);

--     type NeuronRepr(Ni : InputIndex_Base; No : OutputIndex_Base) is record
--         idx     : NNet_NeuronId; -- own index in NNet
--         activat : Activation_Type;
--         lag     : Real;    -- delay of result propagation, unused for now
--         weights : Weight_Array(0 .. Ni);
--         inputs  : Input_Connection_Array  (1 .. Ni);
--         outputs : Output_Connection_Array (1 .. No);
--         -- may add level index this belongs to, to avoid resorting upon structure load..
--     end record;

end dynn.neurons;
