-- dynn.nets package
-- Holds definition of the main type - the NNet, representing the neural net interface.
-- Specifics of data storage is in its children.
--
-- Copyright (C) 2019  <George Shapovalov> <gerrshapovalov@gmail.com>
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
with dynn.layers;
with dynn.inputs;
-- with connectors;

with Ada.Text_IO;

generic
package dynn.nets is

--     package PI  is new dynn.inputs;
--     package PL  is new dynn.layers;
--     package PN renames PL.PN;
    --package PN is new dynn.neurons; -- creates new package with new incompatible types

    -- Unlike inputs, outputs and neurons, layers are *internal* to nnet,
    --  constructed dynamically and processed in order.
    -- They need a real, int-type index.
    type    LayerIndex_Base is new Natural;
    subtype LayerIndex  is LayerIndex_Base  range 1 .. LayerIndex_Base'Last;


    -- similar to Neuron_Interface, NNet_Interface uses same method signature for Outputs
    -- this package encapsulates the common interface, specific by index
--     package PCN is new Connectors(Index_Base      => NNN.OutputIndex_Base,
--                                   Connection_Type => ConnectionIndex,
--                                   No_Connection   => No_Connection );


    -- NOTE: NNet indices are defined at the library level, in the nnet_types package,
    -- as they have to be acessible to all other children


    ---------------------------------------------------------------------------------
    -- the main type of this package, the NNet itself
    --  making it an interface to allow composition (say with Controlled)
    --  also to prototype the data access needs for different variants
    --
    -- This is the base version, consists of stateless neurons (topology and weights only);
    --
    -- Some of the functionality is common to all, and is easiest to implement right here.
    -- So, like with Layer_Interface we make this one abstract tagged, rather than interface.
    -- We have no need for overlaying hierarchies so far..
    type NNet_Interface is abstract limited new PCN.Connector_Interface with private;
    type NNet_Access is access NNet_Interface'Class;




    -----------------------------------------
    -- class-wide stuff:
    --   the main algorithms, accessing data via primitives,
    --   that are operating on real data in child types
    --
    -- Add_Neuron discarding idx
    procedure Add_Neuron(net : in out NNet_Interface'Class; neur : in out PN.Neuron_Interface'Class);

    -- readers from various formats
    -- should take the form:
    procedure Construct_From(net : in out NNet_Interface'Class; S : String);
    -- this should fill the pre-constructed NNet from the given medium (here basic String
    -- is shown as example)
    -- SPecific implementations in child packages may provide a convenience wrappers
    -- in the form of Create_From functions, returning the specific type
    -- (these would do appropriateconstruction via return .. do syntax, passing constructed type to
    -- appropriate Construct_From procedure)

    -- structure monitoring and IO
    procedure Print_Structure(net : NNet_Interface'Class;
                              F : Ada.Text_IO.File_Type := Ada.Text_IO.Standard_Output);
    --
    -- add To_Stream/From_stream and/or To_JSON/From_JSON? methods


    --
    -- Layer handling
    --
    procedure Sort_Layers (net : in out NNet_Interface'Class;
                           LG  : PL.Layer_Generator := Null; -- Null means to use pre-set generator
                           Direction : Sort_Direction := Forward);
    -- perform a topological sort, (re-)creating layers tracking the connections,
    -- to allow optimizations (parallel computation, use of GPU).
    -- raises:
    --   Unset_Layer_Generator  - if LG is Null and generator was not set
    --
    -- Forward and backward sort will produce different layering if cycles are present
    -- (which is a major modus operandi of this lib).

    procedure Update_Layers (net : in out NNet_Interface'Class; idx : NNet_NeuronId); -- needs extra param: add/del op selector
    -- called upon insertion/deletion of a neuron to update pre-sroted layers
    -- if Autosort_Layers = True.
    -- Updates layers starting from the inserted neuron, following its connections.
    -- May be more efficient (O(logN) instead of N*LogN) compared to complete sort.

    -- May need to add a method of sort validation if full state of neurons is saved/loaded


    ------------------------
    --  Propagation
    --
    -- Forward prop through trained net
    -- stateless propagation net state is completely internal to this proc, no side effects
--     function  Prop_Forward(net : NNet_Interface'Class; inputs : NNN.Input_Array)  return NNN.Output_Array;
--     --
--     function  Calc_Outputs(net : NNet_Interface'Class; NSV : NNN.Checked_State_Vector) return NNN.Output_Array;
--     function  Calc_Outputs(net : NNet_Interface'Class; NSV : NNN.State_Vector) return NNN.Output_Array;


private

    type NNet_Interface is abstract limited new PCN.Connector_Interface with record
        autosort_layers : Boolean := False;
        layer_sort_direction  : Sort_Direction := Forward;  -- reset by Sort_Layers
        LG : PL.Layer_Generator := Null;
    end record;


    -- utility primitives and class-wide methods
    function Get_Free_NeuronId(net : NNet_Interface'Class) return NNet_NeuronId; -- might need to be abstract primitive

end dynn.nets;

