library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_signed.all;

library work;
use work.mypackage.all;

entity tb_psf65t is
end tb_psf65t;

architecture behavior of tb_psf65t is
	
    component clockgen port(
		nrst : in std_logic;
		mclk : in std_logic ;
		clk8x : out std_logic;
		clk4x : out std_logic;
		clk2x : out std_logic;
		clk1x : out std_logic
	);
	end component;

	component PSF65Tab port(
		nrst : in std_logic;
		clk : in std_logic;
		PSFin : in std_logic_vector(9 downto 0 );
		PSFout : out std_logic_vector(9 downto 0)
	);
	end component;

	signal nrst, clk8x, clk : std_logic;
	signal xin : std_logic_vector(9 downto 0);
	signal fout : std_logic_vector(9 downto 0);
    signal flag : std_logic;
begin	
	iclk : process
	begin
		clk <= '1';
		wait for 20ns;
		clk <= '0';
		wait for 20ns;
	end process;

	rstp : process
	begin
		nrst <= '0';
		wait for 100ns;
		nrst <= '1';
		wait;
	end process;

    clkgen : clockgen port map(
        nrst => nrst,
		mclk => clk,
		clk8x => clk8x
	);
    imp : process(nrst, clk8x)
    begin
		if nrst ='0' then
            xin  <= "0000000000";
            flag <= '0';
        elsif nrst ='1' and rising_edge(clk8x) then
            if flag = '0' and xin = "0000000000" then
                xin  <= "0111111111";
                flag <= '1';
            end if;
            
            if xin = "0111111111" then
                xin <= "0000000000";
            end if;    
        end if;
 	end process;

	fsp: PSF65Tab port map(
		nrst => nrst,
		clk => clk8x,
		PSFin => xin,
		PSFout => fout
	);

	
end behavior;
