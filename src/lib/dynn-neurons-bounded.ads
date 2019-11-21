--
-- dynn.neurons.bounded package. ACV-based implementation, mutable.
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

with lists.bounded;

generic
package dynn.neurons.bounded is

    type Neuron (maxNi : InputIndex;
                 maxNo : OutputIndex)
        is new Neuron_Interface with private;

    overriding
    function Id (neur : Neuron) return NeuronId;


    overriding
    function Inputs  (neur : in out Neuron) return Input_Reference_Type;

    overriding
    function Outputs (neur : in out Neuron) return Output_Reference_Type;

    overriding
    function Weights (neur : in out Neuron) return Weight_Reference_Type;


    overriding
    function Inputs  (neur : Neuron) return IL.List_Interface'Class;

    overriding
    function Outputs  (neur : Neuron) return OL.List_Interface'Class;

    overriding
    function Weights (neur : Neuron) return WL.List_Interface'Class;

    ---------------
    -- constructors
    --
--     not overriding
--     function Create(NR : NeuronRec) return Neuron;

    not overriding
    function Create(maxNi : InputIndex; maxNo : OutputIndex;
                    activation : Activation_Type;
                    connections : Input_Connection_Array;
                    weights  : Weight_Array) return Neuron;

    not overriding
    function Create(maxNi : InputIndex; maxNo : OutputIndex;
                    activation : Activation_Type;
                    connections : Input_Connection_Array;
                    maxWeight : Real) return Neuron;
    -- Create with weight uniformly distributed in [0 .. maxWeight]


private

    -- needed vector types
--     use type Connection_Index;
    package ILB is new IL.Bounded;
    package OLB is new OL.Bounded;
    package WLB is new WL.Bounded;

--     type Neuron is new PCNV.Connector_Vector and Neuron_Interface with record
    type Neuron (maxNi : InputIndex; maxNo : OutputIndex) is new Neuron_Interface with record
        id     : NeuronId; -- own index in NNet
        activat : Activation_Type;
        my_inputs  : aliased ILB.List(maxNi);
        my_outputs : aliased OLB.List(maxNo);
        my_weights : aliased WLB.List(maxNi);
        bias : Real;
    end record;


end dynn.neurons.bounded;
