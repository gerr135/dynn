pragma Ada_2012;

with Ada.Integer_Text_IO;

package body dynn.neurons is

--     --------------------------------------------------
--     -- basic getters/setters (wrappers around FromRec)
--     --
--     function  ToRec  (NI : Neuron_Interface'Class) return NeuronRec is
--         NRp : NeuronRepr := NI.ToRepr;
--         NR : NeuronRec :=
--             (Ni=>NRp.Ni, idx=> NRp.idx,
--              activat => NRp.activat,
--              lag     => 0.0,
--              weights => NRp.weights,
--              inputs  => NRp.inputs );
--     begin
--         return NR;
--     end;
--
--     function Index (NI : Neuron_Interface'Class) return NN.NeuronIndex is
--     begin
--         return NI.ToRec.idx;
--     end Index;
--
--     function Activation (NI : Neuron_Interface'Class) return Activation_Type is
--     begin
--         return NI.ToRec.activat;
--     end Activation;
--
--     function Weights (NI : Neuron_Interface'Class) return Weight_Array is
--     begin
--         return NI.ToRec.weights;
--     end Weights;
--
--     function Inputs (NI : Neuron_Interface'Class) return Input_Connection_Array is
--     begin
--         return NI.ToRec.inputs;
--     end Inputs;
--
--     function Outputs (NI : Neuron_Interface'Class) return Output_Connection_Array is
--         outs : Output_Connection_Array(1 .. NI.NOutputs);
--     begin
--         for o in 1 .. NI.NOutputs loop
--             outs(o) := NI.Output(o);
--         end loop;
--         return outs;
--     end Outputs;


--     --------------
--     -- Settters
--     --
--     -- ATTN!! looks like this approach (resetting a field via converting back and forth
--     -- through Rec representaition) is causing "errorneour memory access" at run time
--     -- Should probably go back to individual primitives
--     procedure Set_Index (NI : in out Neuron_Interface'Class;
--         idx : NN.NeuronIndex)
--     is
--     begin
--         GT.Trace(Debug, "NI.Set_Index" & idx'Img);
--         declare
--             NR : NeuronRepr := NI.ToRepr;
--         begin
--             NR.idx := idx;
--             NI.FromRepr(NR);
--         end;
--         -- quite cumbersome. May be much better to make it primitive abstract overridable by specific implementation
--     end Set_Index;
--
--     procedure Set_Activation (NI : in out Neuron_Interface'Class;
--                                 activat : Activation_Type)
--     is
--         NR : NeuronRepr := NI.ToRepr;
--     begin
--         NR.activat := activat;
--         NI.FromRepr(NR);
--     end Set_Activation;
--
--     procedure Set_Weights (NI : in out Neuron_Interface'Class;
--                         weights : Weight_Array)
--     is
--         NR : NeuronRepr := NI.ToRepr;
--     begin
--         NR.weights := weights;
--         NI.FromRepr(NR);
--     end Set_Weights;
--
--     procedure Set_Inputs
--         (NI : in out Neuron_Interface'Class;
--         inputs  : Input_Connection_Array)
--     is
--         NR : NeuronRepr := NI.ToRepr;
--     begin
--         NR.inputs := inputs;
--         NI.FromRepr(NR);
--     end Set_Inputs;


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
