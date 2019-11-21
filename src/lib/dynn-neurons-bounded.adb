pragma Ada_2012;

with Ada.Numerics.Float_Random;

package body dynn.neurons.bounded is

    overriding
    function Id (neur : Neuron) return NeuronId is
    begin
        return neur.id;
    end;


    overriding
    function Inputs  (neur : in out Neuron) return Input_Reference_Type is
        IR : not null access IL.List_Interface'Class := neur.my_inputs'Access;
        R : Input_Reference_Type(IR);
    begin
        return R;
    end;

    overriding
    function Outputs (neur : in out Neuron) return Output_Reference_Type is
        R : Output_Reference_Type(neur.my_outputs'Access);
    begin
        return R;
    end;

    overriding
    function Weights (neur : in out Neuron) return Weight_Reference_Type is
        R : Weight_Reference_Type(neur.my_weights'Access);
    begin
        return R;
    end;


    overriding
    function Inputs  (neur : Neuron) return IL.List_Interface'Class is
    begin
        return neur.my_inputs;
    end;

    overriding
    function Outputs (neur : Neuron) return OL.List_Interface'Class is
    begin
        return neur.my_outputs;
    end;

    overriding
    function Weights (neur : Neuron) return WL.List_Interface'Class is
    begin
        return neur.my_weights;
    end;

    ------------
    -- Create --
    ------------

--     not overriding
--     function Create (NR : NeuronRec) return Neuron is
--         neur : Neuron;
--     begin
--         neur.idx := NR.idx;
--         neur.activat := NR.activat;
--         neur.lag := 0.0;
--         -- populate inputs and weights
--         for i in NR.inputs'Range loop
--             neur.inputs.Append(NR.inputs(i));
--         end loop;
--         for w in NR.weights'Range loop
--             neur.weights.Append(NR.weights(w));
--         end loop;
--         return neur;
--     end Create;

    not overriding
    function Create(maxNi : InputIndex; maxNo : OutputIndex;
                    activation : Activation_Type;
                    connections : Input_Connection_Array;
                    weights  : Weight_Array) return Neuron
    is
        neur : Neuron (maxNi, maxNo);
    begin
        -- first some checks
        if maxNi < connections'Length then
            raise Constraint_Error with "too many inputs at bounded neuron creation";
        end if;
        --
        neur.id := +0;
        neur.activat := activation;
        -- populate inputs and weights
        for i in connections'Range loop
            -- NOTE: direct use of neur.my_inputs triggers gnat bug!!
            ILB.List(neur.Inputs.Data.all)(i) := connections(i);
        end loop;
        for w in weights'Range loop
            WLB.List(neur.Weights.Data.all)(w) := weights(w);
            neur.bias := weights(0);
        end loop;
        return neur;
    end Create;

    not overriding
    function Create(maxNi : InputIndex; maxNo : OutputIndex;
                    activation : Activation_Type;
                    connections : Input_Connection_Array;
                    maxWeight : Real) return Neuron
    is
        neur : Neuron (maxNi, maxNo);
        G : Ada.Numerics.Float_Random.Generator;
        use Ada.Numerics.Float_Random;
    begin
        -- first some checks
        if maxNi < connections'Length then
            raise Constraint_Error with "too many inputs at bounded neuron creation";
        end if;
        --
        neur.id := +0;
        neur.activat := activation;
        -- populate inputs and weights
        for i in connections'Range loop
            -- NOTE: direct use of neur.my_inputs triggers gnat bug!!
            Ada.Text_IO.Put_Line("  Create, i=" & i'Img);
            ILB.List(neur.Inputs.Data.all)(i) := connections(i);
        end loop;
        -- generate random weights
        Reset(G);
        for w in 0 .. connections'Last loop
            WLB.List(neur.Weights.Data.all)(w) := Real(Random(G)) * maxWeight;
        end loop;
        return neur;
    end Create;

end dynn.neurons.bounded;
