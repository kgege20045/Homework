library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_signed.all;

library work;
use work.mypackage.all;

entity tb_psf17T2 is
end tb_psf17T2;

architecture behavior of tb_psf17T2 is
 	component psf17T port(
		nrst : in std_logic;
		clk : in std_logic;
		xin : in std_logic_vector(9 downto 0);
		fout : out std_logic_vector(9 downto 0)
	);
	end component;
	
	component PSF17Tab port(
		nrst : in std_logic;
		clk : in std_logic;
		PSFin : in std_logic_vector(9 downto 0 );
		PSFout : out std_logic_vector(9 downto 0)
	);
	end component;

	signal nrst, clk : std_logic;
	signal xin : std_logic_vector(9 downto 0);
	signal fout1, fout2 : std_logic_vector(9 downto 0);
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

	fsp: psf17T port map(
		nrst => nrst,
		clk => clk,
		xin => xin,
		fout => fout1
	);
	
	fsp2: PSF17Tab port map(
		nrst => nrst,
		clk => clk,
		PSFin => xin,
		PSFout => fout2
	);

	imp : process begin
		xin <= "0000000000";
		wait for 140ns;
		xin <= "0111111111";
		wait for 40ns;
		xin <= "0000000000";
		wait;
	end process;
end behavior;
