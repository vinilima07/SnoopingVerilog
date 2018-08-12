library verilog;
use verilog.vl_types.all;
entity projeto is
    generic(
        memTAM          : integer := 6;
        cacheTAM        : integer := 1
    );
    port(
        clock           : in     vl_logic;
        entrada         : in     vl_logic_vector(9 downto 0);
        saida0          : out    vl_logic_vector(2 downto 0);
        saida1          : out    vl_logic_vector(2 downto 0);
        saida2          : out    vl_logic_vector(2 downto 0)
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of memTAM : constant is 1;
    attribute mti_svvh_generic_type of cacheTAM : constant is 1;
end projeto;
