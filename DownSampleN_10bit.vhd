library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity downsample_10bit is
generic (
    rate : integer := 4
);
port(
    nrst : in std_logic;
    clk8x : in std_logic;
    clk4x : in std_logic;
    clk2x : in std_logic;
    clk1x : in std_logic;
    rd8x : in std_logic_vector(9 downto 0);
    id8x : in std_logic_vector(9 downto 0);
    rdnx : out std_logic_vector(9 downto 0);
    idnx : out std_logic_vector(9 downto 0)
);
end downsample_10bit;

architecture arch of downsample_10bit is
    signal cnt : integer range 0 to rate-1;
    signal dndatar : std_logic_vector(9 downto 0);
    signal dndatai : std_logic_vector(9 downto 0);
begin

    process(nrst, clk8x)
    begin
        if nrst = '0' then
            cnt <= 0;
            dndatar <= (others => '0');
            dndatai <= (others => '0');
        elsif rising_edge(clk8x) then
            if cnt = 5 then -- Filter input delay --> 3, not --> 1, 16QAM --> 5
                dndatar <= rd8x;
                dndatai <= id8x;
            end if;

            if cnt = rate-1 then
                cnt <= 0;
            else
                cnt <= cnt + 1;
            end if;
        end if;
    end process;

    gen_qpsk : if rate = 4 generate
        process(nrst, clk2x)
        begin
            if nrst = '0' then
                rdnx <= (others => '0');
                idnx <= (others => '0');
            elsif rising_edge(clk2x) then
                rdnx <= dndatar;
                idnx <= dndatai;
            end if;
        end process;
    end generate;

    gen_16qam : if rate = 8 generate
        process(nrst, clk1x)
        begin
            if nrst = '0' then
                rdnx <= (others => '0');
                idnx <= (others => '0');
            elsif rising_edge(clk1x) then
                rdnx <= dndatar;
                idnx <= dndatai;
            end if;
        end process;
    end generate;

end arch;
