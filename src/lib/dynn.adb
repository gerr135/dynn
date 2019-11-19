pragma Ada_2012;

with Ada.Strings.Fixed;

package body dynn is

    function Con2Str(connection : Connection_Index) return String is
        use Ada.Strings, Ada.Strings.Fixed;
    begin
        return connection.T'Img &
            (case connection.T is
                when None=> "",
                when I   => Trim(int(connection.Iidx)'Img, Side => Both),
                when N   => Trim(int(connection.Nidx)'Img, Side => Both),
                when O   => Trim(int(connection.Oidx)'Img, Side => Both)
            );
    end Con2Str;


    package body Component_Id is

        function "+"(int : Natural) return Id_Type is
        begin
            return Id_Type(int);
        end;

        function int(cId : Id_Type) return Natural is
        begin
            return Integer(cId);
        end;

        function "="(Left : Integer; Right : Id_Type) return Boolean is
        begin
            return Left = Integer(Right);
        end;

        function "="(Left : Id_Type; Right : Integer) return Boolean is
        begin
            return Integer(Left) = Right;
        end;

    end Component_Id;

begin
    GT.Parse_Config_File;
end dynn;
