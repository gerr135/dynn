pragma Ada_2012;

with Ada.Integer_Text_IO;

package body dynn.neurons is


    procedure Print_Structure(neur : Neuron_Interface'Class;
                              F : Ada.Text_IO.File_Type := Ada.Text_IO.Standard_Output)
    is
        use Ada.Text_IO, Ada.Integer_Text_IO;
    begin
        Put("  ");
        Put(F, int(neur.Id), 2);
        Put(" |");
        for input of neur.Inputs loop  -- implement vector-like access by reference
            Put(F, Con2Str(input) & " ");
        end loop;
        Put(F,"|");
        for output of neur.Outputs loop
            Put(F, Con2Str(output) & " "); -- ditto for outputs
        end loop;
        Put_Line(F,";");
    end;

   -----------------
   -- PropForward --
   -----------------

    function Prop_Forward (neur : Neuron_Interface'Class; data  : Value_Array) return Real is
    begin
        --  Generated stub: replace with real body!
        pragma Compile_Time_Warning (Standard.True, "PropForward unimplemented");
        return raise Program_Error with "Unimplemented function PropForward";
    end Prop_Forward;

end dynn.neurons;
