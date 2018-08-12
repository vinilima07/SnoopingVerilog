library verilog;
use verilog.vl_types.all;
entity display7Segmentos is
    port(
        Entrada         : in     vl_logic_vector(2 downto 0);
        SaidaDisplay    : out    vl_logic_vector(0 to 6)
    );
end display7Segmentos;
