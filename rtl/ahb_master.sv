module ahb_design(
  input bit HCLK,
  input bit HRESETn,
  
  // Input signals (from arbiter/slave/external)
  input logic HGRANT,
  input logic HREADY,
  input logic BUSREQ,    // External bus request trigger
  input logic ADDREQ,    // External lock request trigger
  input logic HWRITE,    // Write (1) or read (0)
  input logic [31:0] ADDR,  // Starting address
  input logic [31:0] HWDATA,  // Write data (pipelined)
  input logic [2:0] HSIZE,   // Transfer size (000=byte, 001=halfword, 010=word, etc.)
  input logic [2:0] HBURST,  // Burst type (000=single, 001=incr4, 010=wrap4, etc.)
  input logic [1:0] HRESP,   // Response from slave (00=OKAY, 01=ERROR, 10=RETRY, 11=SPLIT)
  input logic [1:0] HSEL,    // Slave select (if needed; often driven by decoder)
  input logic [1:0] HTRANS,  // Initial transfer type (from external; e.g., 10=NONSEQ to start)
  
  // Output signals (to bus/slave)
  output logic HBUSREQ,
  output logic HLOCK,
  output logic HWRITE_out,
  output logic [31:0] HADDR,
  output logic [31:0] HWDATA_out,
  output logic [1:0] HTRANS_out,
  output logic [1:0] HSEL_out,
  output logic [2:0] HSIZE_out,
  output logic [2:0] HBURST_out
);

// Internal states for FSM
typedef enum logic [2:0] {
  IDLE,
  REQ_BUS,
  ADDR_PHASE,
  DATA_PHASE,
  BURST_CONT,
  ERROR_RETRY
} state_t;
state_t state, next_state;

// Internal registers
logic [31:0] addr_reg;      // Registered start address
logic [31:0] curr_addr;     // Current address (for bursts)
logic write_reg;
logic [2:0] size_reg;
logic [2:0] burst_reg;
logic [1:0] trans_reg;
logic [1:0] sel_reg;
logic lock_reg;             // Lock flag
logic [3:0] burst_cnt;      // Burst counter (max 16 transfers)
logic burst_done;

// Burst length mapping (from HBURST)
function automatic logic [3:0] get_burst_len(logic [2:0] burst);
  case (burst)
    3'b000: return 4'd1;   // SINGLE
    3'b001: return 4'd4;   // INCR4
    3'b011: return 4'd8;   // INCR8
    3'b101: return 4'd16;  // INCR16
    3'b010: return 4'd4;   // WRAP4
    3'b100: return 4'd8;   // WRAP8
    3'b110: return 4'd16;  // WRAP16
    default: return 4'd1;  // Undefined -> SINGLE
  endcase
endfunction

// Address increment/wrap logic
function automatic logic [31:0] next_address(logic [31:0] addr, logic [2:0] size, logic [2:0] burst);
  logic [31:0] incr = 1 << size;  // Byte increment (1,2,4,8,...)
  logic [31:0] wrap_boundary;
  logic [3:0] wrap_size;
  
  case (burst)
    3'b000, 3'b001, 3'b011, 3'b101: begin  // INCR types
      return addr + incr;
    end
    3'b010: begin  // WRAP4
      wrap_size = 4;
      wrap_boundary = wrap_size * (1 << size);
      return ((addr / wrap_boundary) * wrap_boundary) + ((addr + incr) % wrap_boundary);
    end
    3'b100: begin  // WRAP8
      wrap_size = 8;
      wrap_boundary = wrap_size * (1 << size);
      return ((addr / wrap_boundary) * wrap_boundary) + ((addr + incr) % wrap_boundary);
    end
    3'b110: begin  // WRAP16
      wrap_size = 16;
      wrap_boundary = wrap_size * (1 << size);
      return ((addr / wrap_boundary) * wrap_boundary) + ((addr + incr) % wrap_boundary);
    end
    default: return addr + incr;
  endcase
endfunction

// FSM sequential logic
always_ff @(posedge HCLK or negedge HRESETn) begin
  if (!HRESETn) begin
    state <= IDLE;
  end else begin
    state <= next_state;
  end
end

// FSM combinatorial logic
always_comb begin
  next_state = state;
  case (state)
    IDLE: begin
      if (BUSREQ) begin
        next_state = REQ_BUS;
      end
    end
    REQ_BUS: begin
      if (HGRANT && HREADY) begin
        next_state = ADDR_PHASE;
      end
    end
    ADDR_PHASE: begin
      if (HREADY) begin
        next_state = DATA_PHASE;
      end
    end
    DATA_PHASE: begin
      if (HREADY) begin
        if (burst_done) begin
          next_state = IDLE;
        end else begin
          next_state = BURST_CONT;
        end
      end
      if (HRESP inside {2'b01, 2'b10}) begin  // ERROR or RETRY
        next_state = ERROR_RETRY;
      end
    end
    BURST_CONT: begin
      if (HREADY) begin
        next_state = DATA_PHASE;
      end
    end
    ERROR_RETRY: begin
      if (HREADY && HGRANT) begin  // Retry the transfer
        next_state = ADDR_PHASE;
      end
    end
    default: next_state = IDLE;
  endcase
end

// Register inputs and manage burst
always_ff @(posedge HCLK or negedge HRESETn) begin
  if (!HRESETn) begin
    addr_reg <= 32'h0;
    curr_addr <= 32'h0;
    write_reg <= 1'b0;
    size_reg <= 3'b0;
    burst_reg <= 3'b0;
    trans_reg <= 2'b0;
    sel_reg <= 2'b0;
    lock_reg <= 1'b0;
    burst_cnt <= 4'd0;
    HBUSREQ <= 1'b0;
    HLOCK <= 1'b0;
    HADDR <= 32'h0;
    HWRITE_out <= 1'b0;
    HSIZE_out <= 3'b0;
    HBURST_out <= 3'b0;
    HTRANS_out <= 2'b00;  // IDLE
    HSEL_out <= 2'b00;
    HWDATA_out <= 32'h0;
  end else begin
    // Default: hold values
    HBUSREQ <= 0;
    HLOCK <= 0;
    
    case (state)
      IDLE: begin
        burst_cnt <= 4'd0;
        if (BUSREQ) begin
          HBUSREQ <= 1;
          lock_reg <= ADDREQ;
        end
      end
      REQ_BUS: begin
        HBUSREQ <= 1;  // Keep requesting
        HLOCK <= lock_reg;
      end
      ADDR_PHASE: begin
        if (HREADY && HGRANT) begin
          addr_reg <= ADDR;
          curr_addr <= ADDR;
          write_reg <= HWRITE;
          size_reg <= HSIZE;
          burst_reg <= HBURST;
          trans_reg <= HTRANS;  // Start with NONSEQ typically
          sel_reg <= HSEL;
          burst_cnt <= 4'd1;    // First transfer started
          
          // Drive address phase outputs
          HADDR <= ADDR;
          HWRITE_out <= HWRITE;
          HSIZE_out <= HSIZE;
          HBURST_out <= HBURST;
          HTRANS_out <= HTRANS;  // e.g., NONSEQ
          HSEL_out <= HSEL;
          HLOCK <= lock_reg;
          HBUSREQ <= (get_burst_len(HBURST) > 1);  // Keep if burst
        end
      end
      DATA_PHASE: begin
        if (HREADY) begin
          HWDATA_out <= HWDATA;  // Drive data for writes (pipelined)
          
          if (!burst_done) begin
            // Prepare next address for burst
            curr_addr <= next_address(curr_addr, size_reg, burst_reg);
            HADDR <= next_address(curr_addr, size_reg, burst_reg);
            HTRANS_out <= 2'b11;  // SEQ for continuation
            burst_cnt <= burst_cnt + 1;
          end else begin
            HTRANS_out <= 2'b00;  // IDLE after done
            HBUSREQ <= 0;
            HLOCK <= 0;
          end
        end
      end
      BURST_CONT: begin
        if (HREADY) begin
          // Drive next control (SEQ)
          HWRITE_out <= write_reg;
          HSIZE_out <= size_reg;
          HBURST_out <= burst_reg;
          HSEL_out <= sel_reg;
        end
      end
      ERROR_RETRY: begin
        HBUSREQ <= 1;  // Re-request
        burst_cnt <= 4'd0;  // Reset count on error
        curr_addr <= addr_reg;  // Restart from beginning
      end
    endcase
  end
end

// Burst done flag
assign burst_done = (burst_cnt == get_burst_len(burst_reg));

endmodule
