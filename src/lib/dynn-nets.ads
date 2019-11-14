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
with connectors;

with Ada.Text_IO;

generic
package dynn.nets is

    package PI  is new dynn.inputs;
    package PL  is new dynn.layers;
    package PN renames PL.PN;
    --package PN is new dynn.neurons; -- creates new package with new incompatible types


--     -------------------------------------------------------------------
--     --  Local indices - for actual continuous arrays/vectors of entries
--     type    InputIndex_Base is new Natural;
--     subtype InputIndex  is InputIndex_Base  range 1 .. InputIndex_Base'Last;
--     type    OutputIndex_Base is new Natural;
--     subtype OutputIndex is OutputIndex_Base range 1 .. OutputIndex_Base'Last;
--     type    NeuronIndex_Base is new Natural;
    --     subtype NeuronIndex is NeuronIndex_Base range 1 .. NeuronIndex_Base'Last;

    -- Unlike inputs, outputs and neurons, layers are *internal* to nnet, dynamic constructs
    -- it makes sense to have this as a local index
    type    LayerIndex_Base is new Natural;
    subtype LayerIndex  is LayerIndex_Base  range 1 .. LayerIndex_Base'Last;


    -- similar to Neuron_Interface, NNet_Interface uses same method signature for Outputs
    -- this package encapsulates the common interface, specific by index
    package PCN is new Connectors(Index_Base      => NNN.OutputIndex_Base,
                                  Connection_Type => ConnectionIndex,
                                  No_Connection   => No_Connection );


    -- NOTE 1: NNet indices are defined at the library level, in the nnet_types package,
    -- as they have to be acessible to all other children

    -- NOTE 2: 2 paradigms of neural net data flow:
    --   1st: stateless net - net only holds topology and weights,
    --   actual signals are kept in external "state vector".
    --
    --   2nd: stateful net  - signals are passed throgh the net itself,
    --   neurons store not only weights and connections, but also current data output..


    ---------------------------------------------------------------------------------
    -- the main type of this package, the NNet itself
    --  making it an interface to allow composition (say with Controlled)
    --  also to prototype the data access needs for different variants
    --
    -- This is the base version, consists of stateless neurons (topology and weights only);
    -- can be used for "light" forwardProp only, initiated from pre-trained net.
    --
    -- Some of the functionality is common to all, and is easiest to implement right here.
    -- So, like with Layer_Interface we make this one abstract tagged, rather than interface.
    -- We have no need for overlaying hierarchies so far..
    type NNet_Interface is abstract limited new PCN.Connector_Interface with private;
    type NNet_Access is access NNet_Interface'Class;

    -- Dimension getters; the setters are imnplementation-specific
    not overriding
    function NInputs (net : NNet_Interface) return NNN.InputIndex_Base  is abstract;
    overriding  -- from Connectors
    function NOutputs(net : NNet_Interface) return NNN.OutputIndex_Base is abstract;
    not overriding
    function NNeurons(net : NNet_Interface) return NNN.NeuronIndex is abstract;
    not overriding
    function NLayers (net : NNet_Interface) return LayerIndex  is abstract;

    -- net IO
    -- These would be inefficient in dynamic implementations (have to copy entire array to access one element)
    -- The 1st one is not even possible, as inputs have variable number of connections..
    --function  Input_Connections (net : NNet_Interface) return NN.Input_Connection_Array  is abstract;
    --function  Output_Connections(net : NNet_Interface) return NN.Output_Connection_Array is abstract;
    --
    -- So we access by element instead
    -- by internal indices
--     not overriding
    function  Input (net : NNet_Interface; i : NNN.InputIndex)  return PI.Input_Interface'Class is abstract;
    --     function  Input (net : NNet_Interface'Class; i : NN.InputIndex)  return PI.InputRec;
--     overriding
    function  Output(net : NNet_Interface; o : NNN.OutputIndex) return ConnectionIndex is abstract; -- from Connectors
    --
    -- by glocal IDs - NOTE: these might be made class-wide..
    function  Input (net : NNet_Interface'Class; i : NNet_InputId)  return PI.Input_Interface'Class;
    --     function  Input (net : NNet_Interface'Class; i : NN.InputIndex)  return PI.InputRec;
    function  Output(net : NNet_Interface'Class; o : NNet_OutputId) return ConnectionIndex; -- from Connectors

    --  Neuron handling
    -- NNet is conceptually a container. So we store/remove neurons with Add/Del_Neuron.
    -- As we have multiple neuron implementations, specific neurons should be created
    -- by their appropriate constructors and passed to the Add_Neuron method.
    --
    procedure Add_Neuron(net  : in out NNet_Interface;
                         neur : in out PN.Neuron_Interface'Class; -- pass pre-created Neuron
                         idx : out NNet_NeuronId) is abstract;
        -- adds pre-created neuron, return in idx new assigned NN.NeuronIndex
        -- and updates connections (outputs) of other net entities (other neurons, inputs, etc..)
        -- also should invalidate Layers_sorted or call sorting if autosort is set..

    procedure Del_Neuron(net : in out NNet_Interface; idx : NNet_NeuronId) is null;
        -- remove neuron from NNet_Interface,
        -- as with Add, should update connections of affected entities and reset Layers_Sorted or autosort

    -- neuron accessor
    function  Neuron(net : aliased in out NNet_Interface; idx : NNN.NeuronIndex) return PN.Neuron_Reference is abstract;
    function  Neuron(net : aliased in out NNet_Interface'Class; idx : NNet_NeuronId)   return PN.Neuron_Reference;
        -- this provides read-write access via Accessor trick
    --function  Neuron(net : NNet_Interface; idx : NN.NeuronIndex) return PN.Neuron_Interface'Class is abstract;
        -- this provides read-only access, passing by reference (tagged record)


    --  Layer handling
    -- Similar to neurons, Add/Del and accessor primitives
    procedure Add_Layer(net : in out NNet_Interface;
                        L   : in out PL.Layer_Interface'Class; -- pass pre-created Layer
                        idx : out LayerIndex) is abstract;
    --
    procedure Del_Layer(net : in out NNet_Interface; idx : LayerIndex) is null;
    --
    function  Layer(net : aliased in out NNet_Interface; idx : LayerIndex) return PL.Layer_Reference is abstract;
        -- read-write access to Layers
    function  Layer(net : NNet_Interface; idx : LayerIndex) return PL.Layer_Interface'Class  is abstract;
        -- read-only access to layers

    -- Layer sorting/creation prmitives
    function  Layers_Sorted (net : NNet_Interface) return Boolean is abstract;
    --
    function  Autosort_Layers(net : NNet_Interface) return Boolean;
    procedure Set_Autosort_Layers(net : in out NNet_Interface;
                                  Autosort : Boolean;
                                  Direction : Sort_Direction := Forward);


    --------------------------------------------------------------------------------------------------
    --------------------
    --  "cached" nnet
    --  Stores neuron outputs in a state vector, uses base stateless neurons
    type Cached_NNet_Interface is abstract new NNet_Interface with private;
    type Cached_NNet_Access    is access Cached_NNet_Interface;

    function  State(net : Cached_NNet_Interface) return NNN.State_Vector  is abstract;
    procedure Set_State(net : in out Cached_NNet_Interface; NSV : NNN.State_Vector) is abstract;
    -- NOTE: GetInputValues should raise  UnsetValueAccess if called before SetInputValues

    type Cached_Checked_NNet_Interface is abstract new NNet_Interface with private;
    type Cached_Checked_NNet_Access    is access Cached_NNet_Interface;

    function  State(net : Cached_Checked_NNet_Interface) return NNN.Checked_State_Vector  is abstract;
    procedure Set_State(net : in out Cached_Checked_NNet_Interface; NSV : NNN.Checked_State_Vector) is abstract;
    -- NOTE: GetInputValues should raise  UnsetValueAccess if called before SetInputValues

    --------------------
    --  Stateful nnet
    --  Stores neuron outputs in neurons themselves, uses stateful neurons
    type Stateful_NNet_Interface is abstract new NNet_Interface with private;
    type Stateful_NNet_Access    is access Stateful_NNet_Interface;

    function  Input_Values(net : Stateful_NNet_Interface) return NNN.Input_Array is abstract;
    procedure Set_Input_Values(net : in out Stateful_NNet_Interface; IV : NNN.Input_Array) is abstract;
    --
    function  Neuron(net : Stateful_NNet_Interface; idx : NNN.NeuronIndex) return PN.Stateful_NeuronClass_Access is abstract;
    function  Neuron(net : Stateful_NNet_Interface; idx : NNet_NeuronId)   return PN.Stateful_NeuronClass_Access is abstract;
    procedure Add_Neuron(net  : in out Stateful_NNet_Interface;
                         neur : in out PN.Stateful_Neuron_Interface'Class; -- pass pre-created Neuron
                         idx : out NNet_NeuronId) is abstract;



    -----------------------------------------
    -- class-wide stuff
    --
    --  Implementation-independent code for
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
    procedure Print_Structure(net : in out NNet_Interface'Class;
                              F : Ada.Text_IO.File_Type := Ada.Text_IO.Standard_Output);
    --
    -- add To_Stream/From_stream and/or To_JSON/From_JSON? methods

    -- random constructors
    procedure Reconnect_Neuron_At_Random(net : in out NNet_Interface'Class; idx  : NNet_NeuronId; maxConnects : PN.InputIndex_Base := 0);
    procedure Populate_At_Random (net : in out NNet_Interface'Class; Npts : NNet_NeuronId;  maxConnects : PN.InputIndex_Base := 0);
    -- populates net with new neurons or resets existing one to random configuration
    -- Npts needs to be passed in case of empty mutable net, otherwise it simply rearranges existing net.
    --
    -- This interface should be redesigned to be more general:
    -- these methods should take more parameters:
    --   Nconnection_Style - fixed, random: uniform, exp?, given distribution
    --   Ncoonn distribution (optional)
    --   Fraction to inputs/other neurons (or set numbers)
    --   Neuron index distribution type: uniform, exp?, given distribution
    --   Neuron index distribution (optional)


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
    function  Prop_Forward(net : NNet_Interface'Class; inputs : NNN.Input_Array)  return NNN.Output_Array;
    --
    function  Calc_Outputs(net : NNet_Interface'Class; NSV : NNN.Checked_State_Vector) return NNN.Output_Array;
    function  Calc_Outputs(net : NNet_Interface'Class; NSV : NNN.State_Vector) return NNN.Output_Array;

    --  Cached NNet propagation
    --  initial values should be set first with Set_Input_Values and then advanced within net,
    --  no need for passing around intermediate inputs/outputs
    --
    -- first Unchecked version
    function  Input_Values(net : Cached_NNet_Interface'Class) return NNN.Input_Array;
    --
    procedure Set_Input_Values(net : in out Cached_NNet_Interface'Class; IV : NNN.Input_Array);
    --
    procedure Prop_Forward(net : Cached_NNet_Interface'Class);
    --
    function  Calc_Outputs(net : Stateful_NNet_Interface'Class) return NNN.Output_Array;

    --  Checked version
    function  Input_Values(net : Cached_Checked_NNet_Interface'Class) return NNN.Input_Array;
    --
    procedure Set_Input_Values(net : in out Cached_Checked_NNet_Interface'Class; IV : NNN.Input_Array);
    --
    procedure Prop_Forward(net : Cached_Checked_NNet_Interface'Class);
    --
    function  Calc_Outputs(net : Cached_Checked_NNet_Interface'Class) return NNN.Output_Array;


private

    type NNet_Interface is abstract limited new PCN.Connector_Interface with record
        autosort_layers : Boolean := False;
        layer_sort_direction  : Sort_Direction := Forward;  -- reset by Sort_Layers
        LG : PL.Layer_Generator := Null;
    end record;

    type Cached_NNet_Interface is abstract new NNet_Interface with null record;

    type Cached_Checked_NNet_Interface is abstract new NNet_Interface with null record;

    type Stateful_NNet_Interface is abstract new NNet_Interface with null record;

end dynn.nets;
