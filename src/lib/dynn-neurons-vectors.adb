pragma Ada_2012;

with Ada.Numerics.Float_Random;

package body dynn.neurons.vectors is

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
--         -- populate inputs and weights vectors
--         for i in NR.inputs'Range loop
--             neur.inputs.Append(NR.inputs(i));
--         end loop;
--         for w in NR.weights'Range loop
--             neur.weights.Append(NR.weights(w));
--         end loop;
--         return neur;
--     end Create;

    not overriding
    function Create(activation : Activation_Type;
                    connections : Input_Connection_Array;
                    weights  : Weight_Array) return Neuron
    is
        neur : Neuron;
    begin
        neur.id := +0;
        neur.activat := activation;
        neur.lag := 0.0;
        -- populate inputs and weights vectors
        for i in connections'Range loop
            ILV.List(neur.Inputs.Data.all).Append(connections(i));
        end loop;
        for w in weights'Range loop
            WLV.List(neur.Weights.Data.all).Append(weights(w));
        end loop;
        return neur;
    end Create;

    not overriding
    function Create(activation : Activation_Type;
                    connections : Input_Connection_Array;
                    maxWeight : Real) return Neuron
    is
        neur : Neuron;
        G : Ada.Numerics.Float_Random.Generator;
        use Ada.Numerics.Float_Random;
    begin
        neur.id := +0;
        neur.activat := activation;
        neur.lag := 0.0;
        -- populate inputs and weights vectors
        for i in connections'Range loop
            neur.my_inputs.Append(connections(i));
        end loop;
        -- generate random weights
        Reset(G);
        for w in 0 .. connections'Last loop
            neur.my_weights.Append(Real(Random(G)) * maxWeight);
        end loop;
        return neur;
    end Create;

end dynn.neurons.vectors;
