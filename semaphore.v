module Semaphore #(parameter CLK_FREQ = 25_000_000) 
(
    input  wire clk,
    input  wire rst_n,
    input  wire pedestrian,
    output wire green,
    output wire yellow,
    output wire red
);
    
    // Definição dos estados
    localparam STATE_RED    = 2'b00;
    localparam STATE_GREEN  = 2'b01;
    localparam STATE_YELLOW = 2'b10;
    
    // Definição dos tempos em ciclos de clock
    localparam RED_TIME    = 5 * CLK_FREQ;
    localparam GREEN_TIME  = 7 * CLK_FREQ;
    localparam YELLOW_TIME = CLK_FREQ / 2;
    
    // Registradores
    reg [1:0] state, next_state;
    
    // Contador para temporização dos estados
    reg [31:0] counter;
    
    // Saídas
    assign red    = (state == STATE_RED);
    assign green  = (state == STATE_GREEN);
    assign yellow = (state == STATE_YELLOW);
    
    // Estado atual
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= STATE_RED;
            counter <= 0;
        end 

        else begin
            state <= next_state;
            if (state != next_state) begin
                counter <= 0;
            end 
            else begin
                counter <= counter + 1;
            end
        end
    end
    
    // Transição de estados
    always @(*) begin
        case (state)
            STATE_RED: begin
                if (counter >= RED_TIME - 1) begin
                    next_state = STATE_GREEN;
                end 
                else begin
                    next_state = STATE_RED;
                end
            end
            
            STATE_GREEN: begin
                if (pedestrian || (counter >= GREEN_TIME - 1)) begin
                    next_state = STATE_YELLOW;
                end 
                else begin
                    next_state = STATE_GREEN;
                end
            end
            
            STATE_YELLOW: begin
                if (counter >= YELLOW_TIME - 1) begin
                    next_state = STATE_RED;
                end 
                else begin
                    next_state = STATE_YELLOW;
                end
            end
            
            default: next_state = STATE_RED;
        endcase
    end

endmodule