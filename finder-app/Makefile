CC=gcc

# For x86:
# 	make
# For Arm64:
# 	make CROSS_COMPILE=aarch64-none-linux-gnu-

default_rule:
	@echo "default build"
	$(CROSS_COMPILE)$(CC) writer.c -o writer
#	https://embeddedguruji.blogspot.com/2019/02/avoid-gcc-deleting-intermediate-files.html
#	$(CROSS_COMPILE)$(CC) --save-temps writer.c -o writer
	
clean:
	@echo "clean"
	rm -rf *.o writer
#	rm -rf *.o *.s *.i writer
