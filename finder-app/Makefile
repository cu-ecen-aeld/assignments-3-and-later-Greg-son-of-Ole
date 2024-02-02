CC=gcc

# For x86:
# 	make
# For Arm64:
# 	make CROSS_COMPILE=aarch64-none-linux-gnu-

default_rule:
	@echo "default build"
	$(CROSS_COMPILE)$(CC) writer.c -o writer
	
clean:
	@echo "clean"
	rm -rf *.o writer
