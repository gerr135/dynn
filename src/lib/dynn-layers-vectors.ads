--
-- dynn.layers.vectors package.
-- Implements layer storage using Containers.Vectors
--
--  NOTE: delerict module file for now. Due to the whole hierarchy being generic
-- (to allow float precision selection) I cannot use limited with. So all the layer code
-- is kept in dynn.nets for now..
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

generic
package dynn.layers.vectors is

    type Layer is new Layer_Interface with private;

    -- primitives
    overriding
    function  ToRec  (L : Layer) return LayerRec;

    overriding
    procedure FromRec(L : in out Layer; LR : LayerRec);
    --     procedure Clear  (LI : in out Layer_Interface) is abstract;
    --

    overriding
    function  NNeurons(L : Layer) return NeuronIndex_Base;

    overriding
    procedure Add_Neuron(L : in out Layer; Nidx : NNet_NeuronId);
    --     procedure DelNeuron(LI : Layer_Interface; idx : NeuronIndex) is abstract;

    overriding
    function  Neuron(L : Layer; idx : NeuronIndex)   return PN.NeuronClass_Access;
    overriding
    function  Neuron(L : Layer; idx : NNet_NeuronId) return PN.NeuronClass_Access;
    --     procedure SetNeuron(LI : Layer_Interface; idx : NeuronIndex; np : PN.Neuron_Access) is abstract;

--     not overriding
    function Generate return Layer_Interface'Class;

--     function Generate return LayerClass_Access;
    -- calls create and casts the returned access to be used iderctly with generator signature

private

    -- needed vector types
--     use type NN.NeuronIndex;
    package NV is new Ada.Containers.Vectors(Index_Type=>NeuronIndex,  Element_Type=>NNet_NeuronId);

    type Layer is new Layer_Interface with record
--         idx     : NN.LayerIndex_Base; -- own index in NNet  - do we need it?
        neurons : NV.Vector;
    end record;


end dynn.layers.vectors;

