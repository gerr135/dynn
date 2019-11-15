--
-- An implementation of NNet using Ada.Containers.Vectors
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

-- This package alows a mutable NNet "signature" - its inputs/outputs to change their
-- connections and even number. This is not done in the majority of NNet libs out there,
-- but this follow directly the paradigm of this lib - mutable nnets.
--
-- NOTE: conceptually it is possible to fix the number of inputs/outputs but mutate
-- neurons inside. However, practically, we still would have to use mutable representation
-- for the inputs at least, unless we prohibit varying inputs of the 1st neuron layer..
-- As the other combination - fixed neurons but mutable IO - does not even make much sense,
-- we would be blowing up our package hierarchy for unclearly formulated concept.
-- (we would have to have nets.vectors-fixedIO/mutableIO subpackages)
-- So, we keep things simple for the moment..


with Ada.Containers.Vectors;
with Ada.Containers.Indefinite_Vectors;

with dynn.layers.vectors;
with dynn.neurons.vectors;
with connectors.vectors;

generic
package dynn.nets.vectors is

    package PLV  is new PL.vectors;
    package PNV  is new PN.vectors;
    --
    package PCNV is new PCN.vectors(Base=>NNet_Interface);

    ------------------------------
    -- mutable NNet
    --
    type NNet is new PCNV.Connector_Vector with private;

    -- Getters --
    overriding
    function NInputs (net : NNet) return NNN.InputIndex_Base;

    overriding
    function NOutputs(net : NNet) return NNN.OutputIndex_Base;

    overriding
    function NNeurons(net : NNet) return NNN.NeuronIndex;

    overriding
    function NLayers (net : NNet) return LayerIndex;

    -- IO handling --
    overriding
    function  Input (net : aliased in out NNet; i : NNN.InputIndex) return PI.Input_Reference;

    overriding
    function  Output(net : aliased in out NNet; o : NNN.OutputIndex) return Connection_Reference;

    -- this version also has mutable IO, so we need methods to add/remore inputs and outputs
    not overriding
    procedure Add_Input(net : in out NNet; N : NNN.InputIndex := 1);
    -- Append (N) new unconnected inputs. Connections are to be made upon neuron adds/mods

    not overriding
    procedure Del_Input(net : in out NNet; idx : NNN.InputIndex);

    overriding
    procedure Add_Output(net : in out NNet; N : NNN.OutputIndex := 1);

    overriding
    procedure Connect_Output(net : in out NNet; idx : NNN.OutputIndex; val : ConnectionIndex);

    overriding
    procedure Del_Output(net : in out NNet; Output : ConnectionIndex);

    -- neuron handling --
    overriding
    procedure Add_Neuron(net : in out NNet; neur : in out PN.Neuron_Interface'Class;
                         idx : out NNet_NeuronId);

    overriding
    procedure Del_Neuron(net : in out NNet; idx : NNet_NeuronId);

    overriding
    function  Neuron(net : aliased in out NNet; idx : NNN.NeuronIndex) return PN.Neuron_Reference;

    -- Layer handling --
    overriding
    procedure Add_Layer(net : in out NNet; L   : in out PL.Layer_Interface'Class;
                        idx : out LayerIndex);
    --
    overriding
    procedure Del_Layer(net : in out NNet; idx : LayerIndex);

    overriding
    function  Layer(net : aliased in out NNet; idx : LayerIndex) return PL.Layer_Reference;

    overriding
    function  Layer(net : NNet; idx : LayerIndex) return PL.Layer_Interface'Class;

    overriding
    function  Layers_Sorted (net : NNet) return Boolean;


    -------------------
    -- new methods
    not overriding
    function Create(Ni : NNN.InputIndex; No : NNN.OutputIndex) return NNet;
    -- basic constructor
    -- pre-creates given number of (unconnected) inputs and outputs, but no neurons or layers.

    not overriding
    function Create_From(S : string) return NNet;
    -- convenience wrapper around COnstruct_From class-wide in the parent



private


    use type PI.Input_Vector;
    package IV is new Ada.Containers.Vectors(Index_Type=>NNN.InputIndex,  Element_Type=>PI.Input_Vector);

--     use type ConnectionIndex;
    package OV is new Ada.Containers.Vectors(Index_Type=>NNN.OutputIndex, Element_Type=>ConnectionIndex);

    -- utilized vector types
    use type PN.Neuron_Interface;
    package NV is new Ada.Containers.Indefinite_Vectors (
            Index_Type=>NNN.NeuronIndex, Element_Type=>PN.Neuron_Interface'Class);

    use type PLV.Layer;
    package LV is new Ada.Containers.Vectors(Index_Type=>LayerIndex,  Element_Type=>PLV.Layer);

    -- the NNet types themselves
    type NNet is new PCNV.Connector_Vector with record
        inputs  : IV.Vector;
        outputs : OV.Vector;
        neurons : NV.Vector;
        layers  : LV.Vector;
        Layers_Ready : Boolean := False;
    end record;

end dynn.nets.vectors;

