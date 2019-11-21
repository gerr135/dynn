--
-- dynn.neurons.vectors package. ACV-based implementation, mutable.
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

with Ada.Containers.Vectors;
-- with connectors.vectors;

with lists.vectors;

generic
package dynn.neurons.vectors is

    type Neuron is new Neuron_Interface with private;

    overriding
    function Id (neur : Neuron) return NeuronId;

    overriding
    function Inputs  (neur : Neuron) return Input_Reference_Type;

    overriding
    function Outputs (neur : Neuron) return OL.List_Interface'Class;

    overriding
    function Weights (neur : Neuron) return WL.List_Interface'Class;

    ---------------
    -- constructors
    --
--     not overriding
--     function Create(NR : NeuronRec) return Neuron;

    not overriding
    function Create(activation : Activation_Type;
                    connections : Input_Connection_Array;
                    weights  : Weight_Array) return Neuron;

    not overriding
    function Create(activation : Activation_Type;
                    connections : Input_Connection_Array;
                    maxWeight : Real) return Neuron;
    -- Create with weight uniformly distributed in [0 .. maxWeight]


private

    -- needed vector types
--     use type Connection_Index;
    package ILV is new IL.Vectors;
    package OLV is new OL.Vectors;
    package WLV is new WL.Vectors;

--     type Neuron is new PCNV.Connector_Vector and Neuron_Interface with record
    type Neuron is new Neuron_Interface with record
        id     : NeuronId; -- own index in NNet
        activat : Activation_Type;
        lag     : Real;    -- delay of result propagation, unused for now
        my_inputs  : aliased ILV.List;
        my_outputs : OLV.List;
        my_weights : WLV.List;
    end record;


end dynn.neurons.vectors;
