-- The Keccak sponge function, designed by Guido Bertoni, Joan Daemen,
-- Michal Peeters and Gilles Van Assche. For more information, feedback or
-- questions, please refer to our website: http://keccak.noekeon.org/

-- Copyright 2023 PoliTO
-- Solderpad Hardware License, Version 2.1, see LICENSE.md for details.
-- SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1
--
--
-- keccak_datapath: datapath of keccak core.  
-- Modified by Alessandra Dolmeta, Mattia Mirigaldi
-- alessandra.dolmeta@polito.it, mattiamirigaldi.98017@gmail.com
--

library work;
use work.keccak_globals.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;



entity keccak_dp is

    port (
        clk     : in  std_logic;
        rst_n   : in  std_logic;
        start_i : in std_logic; 
        din     : in  std_logic_vector(1599 downto 0);
        ready_o : out std_logic;
        dout    : out std_logic_vector(1599 downto 0));

end keccak_dp;

architecture rtl of keccak_dp is

    --components

    component keccak_round
        port (

            round_in     : in  k_state;
            round_constant_signal    : in std_logic_vector(7 downto 0);
            round_out    : out k_state);

    end component;

    component keccak_round_constants_gen
        port (
            round_number: in unsigned(4 downto 0);
            round_constant_signal_out: out std_logic_vector(7 downto 0));
    end component;
 
   
    -- Internal signal declarations
    ----------------------------------------------------------------------------


    signal reg_data,round_in,round_out: k_state;
    --signal zero_state : k_state;
    signal counter_nr_rounds : unsigned(4 downto 0);
    --signal zero_lane: k_lane;
    --signal zero_plane: k_plane;
    signal round_constant_signal: std_logic_vector(7 downto 0);
    signal compute_permutation : std_logic;
    signal permutation_computed : std_logic;


begin  -- Rtl

    -- port map

    round_map : keccak_round port map(
            round_in              => round_in,
            round_constant_signal => round_constant_signal,
            round_out             => round_out
        );

    round_constants_gen: keccak_round_constants_gen port map(counter_nr_rounds,round_constant_signal);
    
    -- constants signals
    --zero_lane<= (others =>'0');

    --i000: for x in 0 to 4 generate
    --	zero_plane(x)<= zero_lane;
    --end generate;

    --i001: for y in 0 to 4 generate
    --	zero_state(y)<= zero_plane;
    --end generate;

    --map part of the state to a vector
    i001: for y in 0 to 4 generate
        i002: for x in 0 to 4 generate
            i003: for i in 0 to 63 generate
                dout(320*y+64*x+i) <= reg_data(y)(x)(i);
            end generate;
        end generate;
    end generate;



    -- state register and counter of the number of rounds

    p_main : process (clk, rst_n)

    begin  -- process p_main
        if rst_n = '0' then                 -- asynchronous rst_n (active low)
            --reg_data <= zero_state;
            for row in 0 to 4 loop
                for col in 0 to 4 loop
                    for i in 0 to 63 loop
                        reg_data(row)(col)(i)<='0';
                    end loop;
                end loop;
            end loop;
            counter_nr_rounds <= (others => '0');
            permutation_computed <='1';
            compute_permutation <= '0';
        elsif clk'event and clk = '1' then  -- rising clk edge

            if (start_i='1') then
                --reg_data <= zero_state;
                for row in 0 to 4 loop
                    for col in 0 to 4 loop
                        for i in 0 to 63 loop
                            reg_data(row)(col)(i)<='0';
                        end loop;
                    end loop;
                end loop;
                counter_nr_rounds <= (others => '0');
                compute_permutation<='1';
                permutation_computed<= '1';
            else
                if(compute_permutation ='1' and permutation_computed='1') then
                    counter_nr_rounds(4 downto 0)<= (others => '0');
                    counter_nr_rounds(0)<='1';
                    permutation_computed<='0';
                    reg_data<= round_out;
                else
                    if( counter_nr_rounds < 24 and permutation_computed='0') then
                        counter_nr_rounds <= counter_nr_rounds + 1;
                        reg_data<= round_out;

                    end if;
                    if( counter_nr_rounds = 23) then
                        permutation_computed<='1';
                        compute_permutation<='0';
                        counter_nr_rounds<= (others => '0');
                    end if;
                end if;

            end if;
        end if;
    end process p_main;



    
    --rate part
    i10: for row in 0 to 4 generate
        i11: for col in 0 to 4 generate
            i12: for i in 0 to 63 generate
                round_in(row)(col)(i)<= reg_data(row)(col)(i) xor (din((row*64*5)+(col*64)+i) and permutation_computed);
            end generate;
        end generate;
    end generate;

    ready_o<=permutation_computed;

end rtl;
