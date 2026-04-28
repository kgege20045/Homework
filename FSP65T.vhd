library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_signed.all;

library work;
use work.mypackage.all;

entity PSF65Tab is 
port (
	nrst : in std_logic;
	clk : in std_logic;
	PSFin : in std_logic_vector(9 downto 0 );
	PSFout : out std_logic_vector(9 downto 0)
);
end PSF65Tab;

architecture behavior of PSF65Tab is
	signal reg : std_10b_array(64 downto 0);
	signal sum11b : std_11b_array(31 downto 0);
	signal sum21b : std_21b_array(31 downto 0);
	signal sum22b : std_22b_array(15 downto 0);
	signal sum23b  : std_23b_array(7 downto 0);
	signal sum24b: std_24b_array(3 downto 0);
	signal sum25b: std_25b_array(1 downto 0);
	signal sum26b: std_logic_vector(25 downto 0);
	signal sum27b : std_logic_vector(26 downto 0);
	signal center: std_logic_vector(19 downto 0);

	constant hvector : std_10b_array(0 to 32) := 
	std_10b_array'(
		conv_std_logic_vector(4,10),
		conv_std_logic_vector(3,10),
		conv_std_logic_vector(2,10),
		conv_std_logic_vector(-1,10),
		conv_std_logic_vector(-3,10),

		conv_std_logic_vector(-6,10),
		conv_std_logic_vector(-8,10),
		conv_std_logic_vector(-8,10),
		conv_std_logic_vector(-7,10),
		conv_std_logic_vector(-4,10),

		conv_std_logic_vector(1,10),
		conv_std_logic_vector(7,10),
		conv_std_logic_vector(12,10),
		conv_std_logic_vector(16,10),
		conv_std_logic_vector(17,10),

		conv_std_logic_vector(15,10),
		conv_std_logic_vector(10,10),
		conv_std_logic_vector(1,10),
		conv_std_logic_vector(-10,10),
		conv_std_logic_vector(-21,10),

		conv_std_logic_vector(-31,10),
		conv_std_logic_vector(-36,10),
		conv_std_logic_vector(-36,10),
		conv_std_logic_vector(-28,10),
		conv_std_logic_vector(-12,10),

		conv_std_logic_vector(13,10),
		conv_std_logic_vector(43,10),
		conv_std_logic_vector(77,10),
		conv_std_logic_vector(113,10),
		conv_std_logic_vector(145,10),

		conv_std_logic_vector(171,10),
		conv_std_logic_vector(188,10),
		conv_std_logic_vector(193,10)
	);
begin

	process(nrst,clk)
	begin
		if nrst ='0' then 
			reg <= (others => "0000000000");
			PSFout <= (others => '0');
		elsif nrst ='1' and rising_edge(clk) then
			reg(64 downto 1) <= reg(63 downto 0);
			reg(0) <= PSFin;
			if sum27b(8) ='1' then
				PSFout <= sum27b(18 downto 9) + '1';
			else
				PSFout <= sum27b(18 downto 9);
			end if;
		end if;
	end process;

	stage0 : for i in 0 to 31 generate
			sum11b(i) <= sxt(reg(i),11) + sxt(reg(64-i),11);
		end generate;

	stage1 : for i in 0 to 31 generate 
			sum21b(i) <= sum11b(i) * hvector(i);
		end generate;

	center <= reg(32)*hvector(32);

	stage2: for i in 0 to 15 generate
			sum22b(i) <= sxt(sum21b(2*i),22) + sxt(sum21b(2*i+1),22);
		end generate;
	
	stage3: for i in 0 to 7 generate
			sum23b(i) <= sxt(sum22b(2*i),23) + sxt(sum22b(2*i+1),23);
		end generate;

	stage4: for i in 0 to 3 generate
			sum24b(i) <= sxt(sum23b(2*i),24) + sxt(sum23b(2*i+1),24);
		end generate;

	stage5: for i in 0 to 1 generate
			sum25b(i) <= sxt(sum24b(2*i),25) + sxt(sum24b(2*i+1),25);
		end generate;

	sum26b <= sxt(sum25b(0),26) + sxt(sum25b(1),26);
	sum27b <= sxt(sum26b,27) + sxt(center, 27);

end behavior;
