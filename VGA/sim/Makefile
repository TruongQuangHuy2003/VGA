# Variables
IVERILOG = iverilog
VVP = vvp
GTKWAVE = gtkwave

# File lists
RTL_LIST = rtl.f
TB_LIST = tb.f
COMPILE_LIST = compile.f

# Output
OUT = test_bench

# Rules
all: build run wave

build:
	$(IVERILOG) -o $(OUT) -c $(COMPILE_LIST)

run:
	$(VVP) $(OUT)

wave:
	$(GTKWAVE) test_bench.vcd

clean:
	rm -f $(OUT) test_bench.vcd

