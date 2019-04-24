
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity stepper_test is
    Port ( 
			clk : in  STD_LOGIC;
			sw_dir : in  STD_LOGIC;
			sw_enable : in  STD_LOGIC;
			sw_speed_up : in STD_LOGIC;				-- hong ngoai 1 as button1
			sw_speed_down: in STD_LOGIC;			-- hong ngoai 2 as button2
			lcd_rw	: out std_logic;   				-- read & write control
			lcd_e 	: out std_logic;   				-- enable control
			lcd_rs	: out std_logic;   				-- data or command control
			data  	: out std_logic_vector(7 downto 0)); -- data field for transfer from fpga to lcd
end stepper_test;

architecture Behavioral of stepper_test is
	signal count : unsigned(18 downto 0):= (others => '0');
	signal step_count: unsigned(7 downto 0):= (others => '0');
	signal s_speed: integer := 5;
	signal persion_number_go_out: integer := 0;
	signal persion_number_come_in: integer := 0;
	signal count_clk: integer := 0;
	signal clk_1hz: std_logic := '0'; 
	--------------------------------------------------
	constant N: integer :=20; 
	type arr is array (1 to N) of std_logic_vector(7 downto 0);
	--signal datas : arr :=    (X"38",X"0c",X"06",X"01",X"80",
	--X"20",x"20",x"20",x"72",x"70",x"49");
	
	--X"38",X"0c",X"06",X"01",X"80", bytes for init lcd 
	--X"20",x"20",x"20",             bytes for space 
	--x"72",x"70",x"6D"				 bytes for display string "rpm"
	
	-- update string for team
	signal datas : arr :=    (X"38",X"0c",X"06",X"01",X"80",
	x"10",x"20",x"20",x"20",	-- > number_persons_in
	x"C0",							-- endline
	x"11",x"20",x"20",			-- < number_persion_out
	x"20",x"50",x"45",x"52",x"53",x"4F",x"4E");
	-- endline with 0xC0
	-- > 0x10
	-- < 0x11
	type dec is array (0 to 9) of std_logic_vector(7 downto 0);
	signal number : dec := (X"30", X"31",X"32", X"33",X"34", X"35",X"36", X"37",X"38", X"39");
	--------------------------------------------------
begin

----------------------------------------------
Div : process(clk)
	begin
		if(falling_edge(clk)) then 
			if(count_clk < 12000000) then 
				count_clk <= count_clk + 1; 
			else
				count_clk <= 0; 
				clk_1hz <= not clk_1hz; 
			end if; 
		end if; 
	end process; 
-----------------------------------------------
tocdo: process
variable check : integer := 0;
begin
	if(falling_edge(clk_1hz)) then 
		if(sw_speed_up = '1') then 
			if ( check = 3 ) then 
					check := 0;
					if ( persion_number_go_out < 100 ) then 
						persion_number_go_out <= persion_number_go_out + 1;
					end if;
			else 
				if ( check = 1) then 
					check := 0; -- reset state 
				else 
					check := 1;
				end if;
			end if;
		elsif(sw_speed_down = '1') then 
			 if (check = 1) then
					check := 0; -- reset state 
					if ( persion_number_come_in < 100 ) then 
						persion_number_come_in <= persion_number_come_in + 1;
					end if;
			 else 
				if ( check = 3 ) then 
					check := 0;
				else 
					check := 3;
				end if;
				
			 end if;
		end if;
	end if; 
end process;

-----------------------------------------------
lcd_rw <= '0';
-----------------------------------------------
lcd : process(clk)
	variable i : integer := 0;
	variable j : integer := 1;
	begin
	if clk'event and clk = '1' then
		if i <= 1000000 then
			i := i + 1;
			lcd_e <= '1';
			-- bieu dien hang chuc 
			if(j = 8) then
				if(( (persion_number_come_in  / 10) rem  10 )= 1) then data <= X"31"; 
				elsif( ( (persion_number_come_in  / 10) rem  10 ) = 2) then data <= X"32"; 
				elsif( ( (persion_number_come_in  / 10) rem  10 ) = 3) then data <= X"33"; 
				elsif( ( (persion_number_come_in  / 10) rem  10 ) = 4) then data <= X"34"; 
				elsif( ( (persion_number_come_in  / 10) rem  10 )=  5) then data <= X"35"; 
				elsif( ( (persion_number_come_in  / 10) rem  10 ) = 6) then data <= X"36"; 
				elsif( ( (persion_number_come_in  / 10) rem  10 ) = 7) then data <= X"37"; 
				elsif( ( (persion_number_come_in  / 10) rem  10 ) = 8) then data <= X"38";
				elsif( ( (persion_number_come_in  / 10) rem  10 ) = 9) then data <= X"39";				
				end if; 
			elsif(j = 9) then
				if(( persion_number_come_in rem 10 )= 1) then data <= X"31"; 
				elsif( (persion_number_come_in rem 10) = 2) then data <= X"32"; 
				elsif( (persion_number_come_in rem 10) = 3) then data <= X"33"; 
				elsif( (persion_number_come_in rem 10) = 4) then data <= X"34"; 
				elsif( (persion_number_come_in rem 10)=  5) then data <= X"35"; 
				elsif( (persion_number_come_in rem 10) = 6) then data <= X"36"; 
				elsif( (persion_number_come_in rem 10) = 7) then data <= X"37"; 
				elsif( (persion_number_come_in rem 10) = 8) then data <= X"38";
				elsif( (persion_number_come_in rem 10) = 9) then data <= X"39";							
				end if;
			elsif(j = 12) then 
				if(( (persion_number_go_out  / 10) rem  10 )= 1) then data <= X"31"; 
				elsif( ( (persion_number_go_out  / 10) rem  10 ) = 2) then data <= X"32"; 
				elsif( ( (persion_number_go_out  / 10) rem  10 ) = 3) then data <= X"33"; 
				elsif( ( (persion_number_go_out  / 10) rem  10 ) = 4) then data <= X"34"; 
				elsif( ( (persion_number_go_out  / 10) rem  10 )=  5) then data <= X"35"; 
				elsif( ( (persion_number_go_out  / 10) rem  10 ) = 6) then data <= X"36"; 
				elsif( ( (persion_number_go_out  / 10) rem  10 ) = 7) then data <= X"37"; 
				elsif( ( (persion_number_go_out  / 10) rem  10 ) = 8) then data <= X"38";
				elsif( ( (persion_number_go_out  / 10) rem  10 ) = 9) then data <= X"39";				
				end if; 
			elsif(j = 13) then 
				if(( persion_number_go_out rem 10 )= 1) then data <= X"31"; 
				elsif( (persion_number_go_out rem 10) = 2) then data <= X"32"; 
				elsif( (persion_number_go_out rem 10) = 3) then data <= X"33"; 
				elsif( (persion_number_go_out rem 10) = 4) then data <= X"34"; 
				elsif( (persion_number_go_out rem 10)= 5) then data <= X"35"; 
				elsif( (persion_number_go_out rem 10) = 6) then data <= X"36"; 
				elsif( (persion_number_go_out rem 10) = 7) then data <= X"37"; 
				elsif( (persion_number_go_out rem 10) = 8) then data <= X"38";
				elsif( (persion_number_go_out rem 10) = 9) then data <= X"39";				
				end if; 
			-- init lcd 
			else data <= datas(j)(7 downto 0); 
			end if;
		-- delay 
		elsif i > 1000000 and i < 2000000 then
			i := i + 1;
			lcd_e <= '0';
		elsif i = 2000000 then
			j := j + 1;
			i := 0;
		end if;
		if j <= 5  then
			lcd_rs <= '0';    --command signal
		elsif j > 5   then
			lcd_rs <= '1';   --data signal
		end if;
		if j = N+1 then  --repeated display of data
			j := 5;
		end if;
	end if;
end process;

end Behavioral;
