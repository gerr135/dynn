--
-- basic test of neuron creation and props
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--

with Ada.Text_IO, Ada.Integer_Text_IO;
with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;

-- with dynn.nets.vectors;
with dynn.neurons.vectors;

procedure tst_neurons is

    use Ada.Text_IO;

    package PD is new dynn(Real => Float);
    package PN is new PD.neurons;
    package PNV is new PN.vectors;

    use PD;
--     use NNN;

begin  -- main
    Put_Line("creating neurons");
    declare
        neur : PNV.Neuron := PNV.Create(Sigmoid, ((I,+1),(I,+2)), maxWeight => 1.0);
    begin
        Put_Line("added neuron 1 and connected to output 1");
        neur.Print_Structure;
    end;
    --
--     New_Line;
--     Put_Line("creating 2-neuron network");
--     declare
--         neur1 : PNV.Neuron := PNV.Create(Sigmoid, ((I,+1),(I,+2)), maxWeight => 1.0);
--         neur2 : PNV.Neuron := PNV.Create(Sigmoid, ((I,+1),(I,+2)), maxWeight => 1.0);
--         net   : PNetV.NNet := PNetV.Create(Ni=>2, No=>2);
--     begin
--         net.Add_Neuron(neur1);
--         net.Set_Output(+1,(N,+1));
--         net.Add_Neuron(neur2);
--         net.Set_Output(+2,(N,+2));
--         net.Print_Structure;
--     end;
end tst_neurons;
