module hanoi
#(
    parameter S = 4,
    parameter PEG_WIDTH = $clog2(S)-1
)
(
    input clk,
    input rst,
    input [1:0] fr,
    input [1:0] to
);

typedef enum logic [3:0] {
    IDLE,
    MOVE_FROM_PEG0_TO_PEG1,
    MOVE_FROM_PEG0_TO_PEG2,
    MOVE_FROM_PEG1_TO_PEG0,
    MOVE_FROM_PEG1_TO_PEG2,
    MOVE_FROM_PEG2_TO_PEG0,
    MOVE_FROM_PEG2_TO_PEG1
} State;

logic [PEG_WIDTH:0] peg0;
logic [PEG_WIDTH:0] peg1;
logic [PEG_WIDTH:0] peg2;

logic [PEG_WIDTH:0] peg0_count;
logic [PEG_WIDTH:0] peg1_count;
logic [PEG_WIDTH:0] peg2_count;

logic [1:0] from_peg;
logic [1:0] to_peg;
logic [1:0] tmp_disk;

always_ff @(posedge clk)
begin
    State current_state;

    if (rst)
    begin
        peg0_count <= '1;
        peg1_count <= '0;
        peg2_count <= '0;

        peg0 <= '1;
        peg1 <= '0;
        peg2 <= '0;

        from_peg <= '0;
        to_peg <= '0;
    end
    else
    begin
        from_peg <= fr;
        to_peg <= to;

        current_state = IDLE;

        case ({from_peg, to_peg})
            MOVE_FROM_PEG0_TO_PEG1: current_state = MOVE_FROM_PEG0_TO_PEG1;
            MOVE_FROM_PEG0_TO_PEG2: current_state = MOVE_FROM_PEG0_TO_PEG2;
            MOVE_FROM_PEG1_TO_PEG0: current_state = MOVE_FROM_PEG1_TO_PEG0;
            MOVE_FROM_PEG1_TO_PEG2: current_state = MOVE_FROM_PEG1_TO_PEG2;
            MOVE_FROM_PEG2_TO_PEG0: current_state = MOVE_FROM_PEG2_TO_PEG0;
            MOVE_FROM_PEG2_TO_PEG1: current_state = MOVE_FROM_PEG2_TO_PEG1;
        endcase

        case (current_state)
            IDLE: begin end
            default: move_disk(from_peg, to_peg);
        endcase
    end
end

function void move_disk;
    input [1:0] from, to;
    begin
        case ({from, to})
            MOVE_FROM_PEG0_TO_PEG1:
                begin
                    peg0_count <= peg0_count - 1'b1;
                    tmp_disk <= peg0[peg0_count + 1];
                    peg1_count <= peg1_count + 1'b1;
                    peg1[peg1_count] <= tmp_disk;
                end

            MOVE_FROM_PEG0_TO_PEG2:
                begin
                    peg0_count <= peg0_count - 1'b1;
                    tmp_disk <= peg0[peg0_count + 1];
                    peg2_count <= peg2_count + 1'b1;
                    peg2[peg2_count] <= tmp_disk;
                end

            MOVE_FROM_PEG1_TO_PEG0:
                begin
                    peg1_count <= peg1_count - 1'b1;
                    tmp_disk <= peg1[peg1_count + 1];
                    peg0_count <= peg0_count + 1'b1;
                    peg0[peg0_count] <= tmp_disk;
                end

            MOVE_FROM_PEG1_TO_PEG2:
                begin
                    peg1_count <= peg1_count - 1'b1;
                    tmp_disk <= peg1[peg1_count + 1];
                    peg2_count <= peg2_count + 1'b1;
                    peg2[peg2_count] <= tmp_disk;
                end

            MOVE_FROM_PEG2_TO_PEG0:
                begin
                    peg2_count <= peg2_count - 1'b1;
                    tmp_disk <= peg2[peg2_count + 1];
                    peg0_count <= peg0_count + 1'b1;
                    peg0[peg0_count] <= tmp_disk;
                end

            MOVE_FROM_PEG2_TO_PEG1:
                begin
                    peg2_count <= peg2_count - 1'b1;
                    tmp_disk <= peg2[peg2_count + 1];
                    peg1_count <= peg1_count + 1'b1;
                    peg1[peg1_count] <= tmp_disk;
                end
        endcase
    end
endfunction

function bit is_legal_move;
    input [1:0] from, to;
    begin
        is_legal_move = 1'b0;

        case ({from, to})
            MOVE_FROM_PEG0_TO_PEG1: is_legal_move = (peg0[peg0_count] < peg1[peg1_count]);
            MOVE_FROM_PEG0_TO_PEG2: is_legal_move = (peg0[peg0_count] < peg2[peg2_count]);
            MOVE_FROM_PEG1_TO_PEG0: is_legal_move = (peg1[peg1_count] < peg0[peg0_count]);
            MOVE_FROM_PEG1_TO_PEG2: is_legal_move = (peg1[peg1_count] < peg2[peg2_count]);
            MOVE_FROM_PEG2_TO_PEG0: is_legal_move = (peg2[peg2_count] < peg0[peg0_count]);
            MOVE_FROM_PEG2_TO_PEG1: is_legal_move = (peg2[peg2_count] < peg1[peg1_count]);
        endcase
    end
endfunction

default clocking
    @(posedge clk);
endclocking

default disable iff (rst);

assume_legal_move: assume property (is_legal_move(from_peg, to_peg) == 1'b1);

cover property (peg0_count == '1);
cover property (peg0_count == '0);
cover property (peg1_count == '0);
cover property (peg2_count == '0);

endmodule
