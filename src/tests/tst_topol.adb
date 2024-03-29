--
-- base test unit constructing small nnets
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--

with Ada.Command_Line, GNAT.Command_Line;
with Ada.Text_IO, Ada.Integer_Text_IO;
with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;

with dynn.nets.vectors;
with dynn.neurons.vectors;

procedure tst_topol is

    use Ada.Text_IO;

    package PW is new dynn(Real => Float);
    package PNet   is new PW.nets;
    package PNetV  is new PNet.vectors;
    package PN renames PNet.PN;
    package PNV is new PN.vectors;

    use PW; use NN;

begin  -- main
    Put_Line("creating basic 1-neuron network");
    declare
        neur : PNV.Neuron := PNV.Create(Sigmoid, ((I,1),(I,2)), maxWeight => 1.0);
        net  : PNetV.NNet := PNetV.Create(Ni=>2, No=>1);
    begin
        net.Add_Neuron(neur);
        net.Connect_Output(1,(N,1));
        -- Add_Output is called implicitly by Create above
        -- all outputs are already pre-created, we just need to connect them..
        Put_Line("added neuron 1 and connected to output 1");
        net.Print_Structure;
    end;
    --
    New_Line;
    Put_Line("creating 2-neuron network");
    declare
        neur1 : PNV.Neuron := PNV.Create(Sigmoid, ((I,1),(I,2)), maxWeight => 1.0);
        neur2 : PNV.Neuron := PNV.Create(Sigmoid, ((I,1),(I,2)), maxWeight => 1.0);
        net   : PNetV.NNet := PNetV.Create(Ni=>2, No=>2);
    begin
        net.Add_Neuron(neur1);
        net.Connect_Output(1,(N,1));
        net.Add_Neuron(neur2);
        net.Connect_Output(2,(N,2));
        net.Print_Structure;
    end;
    --
    New_Line;
    Put_Line("creating 2-layer network from 3 neurons");
    declare
        neur1 : PNV.Neuron := PNV.Create(Sigmoid, ((I,1),(I,2)), maxWeight => 1.0);
        neur2 : PNV.Neuron := PNV.Create(Sigmoid, ((I,1),(I,2)), maxWeight => 1.0);
        neur3 : PNV.Neuron := PNV.Create(Sigmoid, ((N,1),(N,2)), maxWeight => 1.0);
        net   : PNetV.NNet := PNetV.Create(Ni=>2, No=>1);
    begin
        net.Add_Neuron(neur1);
        net.Add_Neuron(neur2);
        net.Add_Neuron(neur3);
        net.Connect_Output(1,(N,3));
        net.Print_Structure;
    end;
end tst_topol;
