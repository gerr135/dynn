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

with dynn.neurons.vectors;
with dynn.neurons.bounded;

procedure tst_neurons is

    use Ada.Text_IO;

    package PD is new dynn(Real => Float);
    package PN is new PD.neurons;
    package PNV is new PN.vectors;
    package PNB is new PN.bounded;

    use PD;

begin  -- main
    Put_Line("creating vector neurons");
    declare
        neur : PNV.Neuron := PNV.Create(Sigmoid, ((I,+1),(I,+2)), maxWeight => 1.0);
    begin
        Put_Line("neuron 1:");
        neur.Print_Structure;
    end;
    --
    New_Line;
    Put_Line("creating bounded neurons");
    declare
        neur : PNB.Neuron := PNB.Create(2, 2, Sigmoid, ((I,+1),(I,+2)), maxWeight => 1.0);
    begin
        Put_Line("neuron 1:");
        neur.Print_Structure;
    end;
end tst_neurons;
