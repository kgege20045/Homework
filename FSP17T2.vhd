library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_signed.all;

library work;
use work.mypackage.all;

entity PSF17Tab is 
port (
	nrst : in std_logic;
	clk : in std_logic;
	PSFin : in std_logic_vector(9 downto 0 );
	PSFout : out std_logic_vector(9 downto 0)
);
end PSF17Tab;

architecture behavior of PSF17Tab is
	signal reg : std_10b_array(16 downto 0);
	signal sum11b : std_11b_array(7 downto 0);
	signal sum21b : std_21b_array(7 downto 0);
	signal sum22b : std_22b_array(3 downto 0);
	signal sum23b  : std_23b_array(1 downto 0);
	signal sum24b: std_logic_vector(23 downto 0);
	signal sum25b : std_logic_vector(24 downto 0);
	signal center: std_logic_vector(19 downto 0);

	constant hvector : std_10b_array(0 to 8) := 
	std_10b_array'(
		conv_std_logic_vector(14,10),
		conv_std_logic_vector(-14,10),
		conv_std_logic_vector(-44,10),
		conv_std_logic_vector(-51,10),
		conv_std_logic_vector(-16,10),
		conv_std_logic_vector(61,10),
		conv_std_logic_vector(159,10),
		conv_std_logic_vector(241,10),
		conv_std_logic_vector(273,10)
	);
begin

	process(nrst,clk)
	begin
		if nrst ='0' then 
			reg <= (others => "0000000000");
			PSFout <= (others => '0');
		elsif nrst ='1' and rising_edge(clk) then
			reg(16 downto 1) <= reg(15 downto 0);
			reg(0) <= PSFin;
			PSFout <= sum25b(18 downto 9);
		end if;
	end process;

	stage0 : for i in 0 to 7 generate
			sum11b(i) <= sxt(reg(i),11) + sxt(reg(16-i),11);
		end generate;

	stage1 : for i in 0 to 7 generate 
			sum21b(i) <= sum11b(i) * hvector(i);
		end generate;

	center <= reg(8)*hvector(8);

	stage2: for i in 0 to 3 generate
			sum22b(i) <= sxt(sum21b(2*i),22) + sxt(sum21b(2*i+1),22);
		end generate;
	
	stage3: for i in 0 to 1 generate
			sum23b(i) <= sxt(sum22b(2*i),23) + sxt(sum22b(2*i+1),23);
		end generate;

	sum24b <= sxt(sum23b(0),24) + sxt(sum23b(1),24);
	sum25b <= sxt(sum24b,25) + sxt(center, 25);

end behavior;
