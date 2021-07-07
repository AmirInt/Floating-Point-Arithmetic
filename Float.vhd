library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Float is
	Port(
		A: in std_logic_vector(7 downto 0);
		B: in std_logic_vector(7 downto 0);
		Operation: in std_logic;
		O: out std_logic_vector(7 downto 0)
	);
end Float;

architecture Behavioral of Float is

begin

	Process(A, B, Operation)

		variable as: std_logic; -- Sign of A
		variable bs: std_logic; -- Sign of B
		variable ae: std_logic_vector(2 downto 0); -- Exponent of A
		variable be: std_logic_vector(2 downto 0); -- Exponent of B
		variable am: std_logic_vector(4 downto 0); -- Mantissa of A
		variable bm: std_logic_vector(4 downto 0); -- Mantissa of B
		variable os: std_logic; -- Sign of result
		variable oe: std_logic_vector(2 downto 0); -- Exponent of result
		variable om: std_logic_vector(5 downto 0); -- Mantissa of result
		variable r: integer;
		
		begin
		
			as := A(7);
			bs := B(7);
			ae := A(6 downto 4);
			be := B(6 downto 4);
			am := '1' & A(3 downto 0);
			bm := '1' & B(3 downto 0);
			r := 1;
			
			-- If A = 0, O <= B
			-- If B = 0, O <= A
			if (B = "00000000") then
				os := as;
				oe := ae;
				om := '0' & am;
			elsif (A = "00000000") then
				-- Turning subtraction into addition
				bs := B(7) xor Operation;
				os := bs;
				oe := be;
				om := '0' & bm;
			
			else
				-- Turning subtraction into addition
				bs := B(7) xor Operation;

				-- Bringing to the same exponent of the bigger number
				if (ae > be) then
					oe := ae;
					r := to_integer(unsigned(ae) - unsigned(be));
					for i in 1 to 7 loop
						bm := '0' & bm(4 downto 1);
						if (i = r) then
							exit;
						end if;
					end loop;
				else
					oe := be;
					r := to_integer(unsigned(be) - unsigned(ae));
					for i in 1 to 7 loop
						am := '0' & am(4 downto 1);
						if (i = r) then
							exit;
						end if;
					end loop;
				end if;

				-- If A and B have the same sign:
				if (as = bs) then
					os := as;
					om := std_logic_vector(unsigned('0' & am) + unsigned('0' & bm));
				else -- If A and B have different signs:
					if (am > bm) then
						os := as;
						om := std_logic_vector(unsigned('0' & am) - unsigned('0' & bm));
					else
						os := bs;
						om := std_logic_vector(unsigned('0' & bm) - unsigned('0' & am));
					end if;
				end if;
				
				-- Converting the result into scientific notation.
				if (om(5) = '1') then
					om := '0' & om(5 downto 1);
					oe := std_logic_vector(unsigned(oe) + 1);
				elsif (om(4) = '0') then
					for i in 3 downto 0 loop
						if (om(i) = '1') then
							for j in 1 to 4 - i loop
								om := om(4 downto 0) & '0';
								oe := std_logic_vector(unsigned(oe) - 1);
							end loop;
							exit;
						end if;
					end loop;
				end if;
				
			end if;
			
			O <= os & oe & om(3 downto 0);

		end Process;


end Behavioral;

