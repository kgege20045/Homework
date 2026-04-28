library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_signed.all;

library work;
use work.mypackage.all;

entity tb_16QAMPSF65Tab is
end tb_16QAMPSF65Tab;

architecture behavior of tb_16QAMPSF65Tab is

	component clockgen port(
		nrst : in std_logic;
		mclk : in std_logic ;
		clk8x : out std_logic;
		clk4x : out std_logic;
		clk2x : out std_logic;
		clk1x : out std_logic
	);
	end component;

	component rb12gen port(
		nrst: in std_logic;
		clk : in std_logic;
		rbit : out std_logic
	);
	end component;

	component S2Pgeneric 
	generic(prate: integer);	
	port(
		nrst : in std_logic;
		sclk : in std_logic;
		pclk : in std_logic;
		inbit : in std_logic;

		outbits : out std_logic_vector((prate -1)downto 0)
	);
	end component;

	component QAM16Mapper port(
		nrst : in std_logic;
		pclk : in std_logic;
		inbits : in std_logic_vector(3 downto 0); 
		rmapout : out std_logic_vector(5 downto 0); 
		imapout : out std_logic_vector(5 downto 0)); 
	end component;

	component upsampleN
	generic ( rate : in integer );
	port(
    		nrst  : in std_logic;
    		clk8x : in std_logic;
   		clk2x : in std_logic;
    		clk1x : in std_logic;
    		rdata : in std_logic_vector(5 downto 0);
    		idata : in std_logic_vector(5 downto 0);

    		rdnx  : out std_logic_vector(5 downto 0);
    		idnx  : out std_logic_vector(5 downto 0)
	);
	end component;
	
	component PSF65Tab port(
		nrst : in std_logic;
		clk : in std_logic;
		PSFin : in std_logic_vector(9 downto 0);
		PSFout : out std_logic_vector(9 downto 0)
	);
	end component;
	
	component downsample_10bit
	generic (rate : in integer);
	port(
		nrst : in std_logic;
		clk8x, clk4x,clk2x, clk1x : in std_logic;
		rd8x, id8x : in std_logic_vector(9 downto 0);
	
		rdnx, idnx : out std_logic_vector(9 downto 0));
	end component;

	component QAM16demapper port(
		nrst : in std_logic;
		clk : in std_logic;
		rdata : in std_logic_vector(5 downto 0);
		idata : in std_logic_vector(5 downto 0);
		demapbits : out std_logic_vector(3 downto 0)
	);
	end component;

	component P2Sgeneric
	generic(prate : integer);
	port(
		nrst : in std_logic;
		sclk : in std_logic ;
		inbits : in std_logic_vector((prate -1) downto 0);

		outbit : out std_logic
	);
	end component;

	signal mclk, nrst : std_logic;
	signal clk1x, clk2x, clk4x, clk8x : std_logic;
	signal inbit : std_logic;
	signal outbits : std_logic_vector(3 downto 0);
	signal rmapout, imapout : std_logic_vector(5 downto 0);
	signal uprmap, upimap : std_logic_vector(5 downto 0);
	signal psfinr, psfini : std_logic_vector(9 downto 0);
	signal rfout1 , ifout1 : std_logic_vector(9 downto 0);
	
	signal rfout2, ifout2 : std_logic_vector(9 downto 0);
	signal rdnout, idnout  : std_logic_vector(9 downto 0);
	signal rdnout6b, idnout6b : std_logic_vector(5 downto 0);
	signal dmapout: std_logic_vector(3 downto 0);
	signal p2sout : std_logic;

begin 
	psfinr <= uprmap &"0000";
	psfini <= upimap &"0000";
	rdnout6b <= rdnout(9 downto 4);
	idnout6b <= idnout (9 downto 4);

	irbgen: rb12gen port map(
		nrst => nrst,
		clk => clk4x,
		rbit => inbit

	);
	
	iclkgen : clockgen port map(
		nrst => nrst,
		mclk => mclk,
		clk8x => clk8x,
		clk4x => clk4x,
		clk2x => clk2x,
		clk1x => clk1x
	);
	
	is2p : S2Pgeneric
		generic map(prate => 4)
		port map(
		nrst => nrst,
		sclk => clk4x,
		pclk => clk1x,
		inbit => inbit,
		outbits => outbits
	);
	
	iqm : QAM16Mapper port map(
		nrst => nrst,
		pclk => clk1x,
		inbits => outbits,
		rmapout => rmapout,
		imapout => imapout
	);

	iup : upsampleN
        generic map(rate => 8)
        port map(
		nrst => nrst,
        clk8x => clk8x,
        clk2x => clk2x,
		clk1x => clk1x,
		rdata => rmapout,
		idata => imapout,
		rdnx => uprmap,
		idnx => upimap
	);
	
	ipsfr1 : PSF65Tab  port map(
		nrst => nrst,
		clk => clk8x,
		PSFin => psfinr,
		PSFout => rfout1
	);

	ipsfi1 : PSF65Tab  port map(
		nrst => nrst,
		clk => clk8x,
		PSFin => psfini,
		PSFout => ifout1
	);
	
	ipsfr2 : PSF65Tab  port map(
		nrst => nrst,
		clk => clk8x,
		PSFin => rfout1,
		PSFout => rfout2
	);
	
	ipsfi2 : PSF65Tab  port map(
		nrst => nrst,
		clk => clk8x,
		PSFin => ifout1,
		PSFout => ifout2
	);

	idn : downsample_10bit
		generic map (rate => 8)
		port map(
		nrst => nrst,
		clk8x => clk8x,
		clk4x => '0',
        clk2x => '0',
		clk1x => clk1x,
		rd8x => rfout2,
		id8x => ifout2,
		rdnx => rdnout,
		idnx => idnout
	);

	idqm  : QAM16demapper port map(
		nrst => nrst,
		clk => clk1x,
		rdata => rdnout6b,
		idata => idnout6b,
		demapbits => dmapout
	);
		
	ip2s : P2Sgeneric
		generic map( prate=> 4)
		port map(
		nrst => nrst,
		sclk => clk4x,
		inbits => dmapout,
		outbit => p2sout
	);

	tb: process 
	begin
		mclk <= '1';
		wait for 20ns;
		mclk <= '0';
		wait for 20ns;
	end process;

	rstp : process
	begin
		nrst <= '0';
		wait for 100ns;
		nrst <= '1';
		wait;
	end process;

end behavior;
