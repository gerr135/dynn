pragma Ada_2012;

-- with Ada.Text_IO;
package body dynn.nets.vectors is

    -------------------
    -- Dimension getters
    --
    overriding
    function NInputs (net : NNet) return NNN.InputIndex_Base is
    begin
        return NNN.InputIndex_Base(net.inputs.Length);
    end;

    overriding
    function NOutputs(net : NNet) return NNN.OutputIndex_Base is
    begin
        return NNN.OutputIndex_Base(net.outputs.Length);
    end;

    overriding
    function NNeurons (net : NNet) return NNN.NeuronIndex is
    begin
        return NNN.NeuronIndex_Base(net.neurons.Length);
    end NNeurons;

    overriding
    function NLayers (net : NNet) return LayerIndex is
    begin
        return LayerIndex_Base(net.layers.Length);
    end NLayers;

    ---------------------------
    -- IO handling
    --
    overriding
    function  Input (net : aliased in out NNet; i : NNN.InputIndex)  return PI.Input_Reference is
        IVR : IV.Reference_Type := net.inputs.Reference(i);
        IR  : PI.Input_Reference(IVR.Element);
    begin
        return IR;
    end;

    overriding
    function  Output(net : aliased in out NNet; o : NNN.OutputIndex) return Connection_Reference is
        OVR : OV.Reference_Type := net.outputs.Reference(o);
    begin
        return OVR.Element;
    end;

    --------------------
    -- Neurons handling
    --
    overriding
    procedure Add_Neuron (net : in out NNet;
                          neur : in out PN.Neuron_Interface'Class;
                          idx : out NNet_NeuronId)
    is
        use type Ada.Containers.Count_Type;
    begin
        -- generate new index
        idx := net.Get_Free_NeuronId;
        GT.Trace(Debug, "net.Add_Neuron" & int(idx)'Img);
        -- set generated idx in neuron and add it to the NNet container
        neur.Set_Index(idx);
        net.neurons.Append(neur);
        -- now connect neuron inputs to outputs of other entities that are already in NNet
        for input : ConnectionIndex of neur.Inputs loop
            GT.Trace(Debug, "  adding input  (" & Con2Str(input) & ")");
            case input.T is
                when dynn.I => net.input (input.Iidx).Add_and_Connect((N,idx));
                when dynn.N => net.neuron(input.Nidx).Add_and_Connect((N,idx));
                when dynn.O | None => raise Invalid_Connection;
            end case;
        end loop;
        -- check if we autosort layers
        if net.autosort_layers then
            net.Update_Layers(idx);
        end if;
    end Add_Neuron;

    overriding
    procedure Del_Neuron (net : in out NNet; idx : NNet_NeuronId) is
        neur : PN.Neuron_Interface'Class := net.Neuron(idx);
        self : ConnectionIndex := (N, idx);
    begin
        -- first disconnect the connections
        for input : ConnectionIndex of neur.Inputs loop
            case input.T is
                when dynn.I => net.input (input.Iidx).Del_Output(self);
                when dynn.N => net.neuron(input.Nidx).Del_Output(self);
                when dynn.O | None => raise Invalid_Connection;
            end case;
        end loop;
        for output : ConnectionIndex of neur.Outputs loop
            case output.T is
                when dynn.I | None => raise Invalid_Connection;
                when dynn.N => net.neuron(output.Nidx).Del_Input(self);
                when dynn.O => net.output(output.Oidx) := (T => None);
            end case;
        end loop;
        -- Now for the tricky part
        -- Need to delete the neuron
        -- and liberate its idx, by compacting all other entries
        -- and updating corresponding indices of all affected connections
        --
        -- Implementation postponed until design is clear:
        -- there are multiple possible approaches on how to handle deletions:
        -- 1. we can update all the indices upon every deletion.
        --    Less efficient, as every delete can force renumbering of the same indices
        --    but can use A.C.Vectors directly.
        -- 2. Can keep indices unchanged upon deletion, and update them by a separate "compact" procedure.
        --    more eofficient, but less automatic - need not forget to call compact if needed.
        --    A.C.Vectors autocompacts upon deletion, so cannot be used as is. Need another
        --    container that supports sparse indexing..
        -- (see also Readme)
        pragma Compile_Time_Warning (Standard.True, "Del_Neuron unimplemented");
        raise Program_Error with "Unimplemented procedure Del_Neuron";
    end Del_Neuron;

    overriding
    function Neuron (net : aliased in out NNet; idx : NNN.NeuronIndex)
        return PN.Neuron_Reference
    is
        NVR : NV.Reference_Type := net.neurons.Reference(idx);
        NR  : PN.Neuron_Reference(NVR.Element);
    begin
        return NR;
    end Neuron;

--     overriding
--     function Neuron (net : NNet; idx : NN.NeuronIndex)
--         return PN.Neuron_Interface'Class
--     is
--     begin
--         return net.neurons.Element(idx);
--     end Neuron;


    ------------------------
    -- Layer handling
    overriding
    procedure Add_Layer(net : in out NNet; L   : in out PL.Layer_Interface'Class;
                        idx : out LayerIndex)
    is
    begin
        pragma Compile_Time_Warning (Standard.True, "Add_Layer unimplemented");
        raise Program_Error with "Unimplemented procedure Add_Layer";
    end;

    overriding
    procedure Del_Layer(net : in out NNet; idx : LayerIndex) is
    begin
        pragma Compile_Time_Warning (Standard.True, "Del_Layer unimplemented");
        raise Program_Error with "Unimplemented procedure Del_Layer";
    end;

    overriding
    function  Layer(net : aliased in out NNet;
                    idx : LayerIndex) return PL.Layer_Reference is
        LVR : LV.Reference_Type := net.layers.Reference(idx);
        LR  : PL.Layer_Reference(LVR.Element);
    begin
        return LR;
    end Layer;

    overriding
    function Layer (net : NNet; idx : LayerIndex)
        return PL.Layer_Interface'Class
    is
    begin
        return net.layers.Element(idx);
    end Layer;

    overriding
    function Layers_Sorted (net : NNet) return Boolean is
    begin
        return net.Layers_Ready;
    end Layers_Sorted;


    -------------------------------------------------------
    --  new methods
    --
    -- Constructors
    --
    not overriding
    function Create(Ni : NNN.InputIndex; No : NNN.OutputIndex) return NNet is
        emptyInput  : PI.Input_Vector;
        emptyOutput : ConnectionIndex := (T=>None);
    begin
        return net : NNet do
            net.inputs.Append(emptyInput, Ada.Containers.Count_Type(Ni));
            net.outputs.Append(emptyOutput, Ada.Containers.Count_Type(No));
            -- the rest of fields are autoinit to proper (emty vector) values
        end return;
    end;

    not overriding
    function Create_From(S : string) return NNet is
    begin
        return net : NNet do
            net.Construct_From(S);
        end return;
    end;


    ---------------------------------------------------------
    -- Input handling

    not overriding
    procedure Add_Input(net : in out NNet; N : NNN.InputIndex := 1) is
        emptyInput  : PI.Input_Vector;
    begin
        net.inputs.Append(emptyInput, Ada.Containers.Count_Type(N));
    end;

    not overriding
    procedure Del_Input(net : in out NNet; idx : NNN.InputIndex) is
    begin
        -- as with Neuron deletion, this is a tricky issue, as it may require reindexing
        -- many connections
        -- Postponed until design is clear
        pragma Compile_Time_Warning (Standard.True, "Del_Input unimplemented");
        raise Program_Error with "Unimplemented procedure Del_Input";
    end;

    overriding
    procedure Add_Output(net : in out NNet; N : NNN.OutputIndex := 1) is
        emptyOutput  : ConnectionIndex := (T=>None);
    begin
        net.outputs.Append(emptyOutput, Ada.Containers.Count_Type(N));
    end;

    overriding
    procedure Connect_Output(net : in out NNet; idx : NNN.OutputIndex; val : ConnectionIndex) is
    begin
        -- A NNet output takes signal from a single neuron or input
        -- but we have to set both sides of a connection
        net.outputs.Replace_Element(idx, val);  -- direct assignment raises "discriminant check failed" here..
        case val.T is
            when I => net.input (val.Iidx).Add_and_Connect((O,idx));
            when N => net.neuron(val.Nidx).Add_and_Connect((O,idx));
            when O | None => raise Invalid_Connection;
        end case;
    end;

    overriding
    procedure Del_Output(net : in out NNet; Output : ConnectionIndex) is
    begin
        -- as with Neuron deletion, this is a tricky issue, as it may require reindexing
        -- many connections
        -- Postponed until design is clear
        pragma Compile_Time_Warning (Standard.True, "Del_Output unimplemented");
        raise Program_Error with "Unimplemented procedure Del_Output";
    end;

end dynn.nets.vectors;
