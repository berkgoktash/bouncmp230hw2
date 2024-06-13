.section .bss
input_buffer: .space 256            # Allocate 256 bytes for input buffer
output_buffer: .space 12          # Allocate 12 bytes for output buffer

.section .data
addi_1:
    .string " 00000 000 00010 0010011\n"    # String for the first pop
addi_2:
    .string " 00000 000 00001 0010011\n"     # String for the second pop
add_op:
    .string "0000000 00010 00001 000 00001 0110011\n"     # String for the add operation
mul_op:
    .string "0000001 00010 00001 000 00001 0110011\n"     # String for the multiplication operation
sub_op:
    .string "0100000 00010 00001 000 00001 0110011\n"     # String for the subtraction operation
xor_op:
    .string "0000100 00010 00001 000 00001 0110011\n"     # String for the xor operation
and_op:
    .string "0000111 00010 00001 000 00001 0110011\n"     # String for the and operation
or_op:
    .string "0000110 00010 00001 000 00001 0110011\n"     # String for the or operation

.section .text
.global _start

_start:
    # Read input from standard input
    mov $0, %eax                    # Syscall number for sys_read
    mov $0, %edi                    # File descriptor 0 (stdin)
    lea input_buffer(%rip), %rsi    # Pointer to the input buffer
    mov $256, %edx                  # Maximum number of bytes to read
    syscall                         # Perform the syscall
    
    call parse_and_evaluate  # Parse and evaluate the expression

parse_and_evaluate:
parse_loop:
    movb (%rsi), %al                # Load current character
    test %al, %al                   # Check for end of input (null terminator)
    jz exit_program                 # Finish if end of input
    mov $'\n', %bl
    movb %al, %dl                   # Check for newline character
    cmp %dl, %bl                
    je exit_program                 # Exit if newline character

    # Skip spaces
    cmp $' ', %al
    je increment_pointer

    # Check if the character is a digit
    cmp $'0', %al
    jl check_operator
    cmp $'9', %al
    jg check_operator

    # Move to number parsing routine
    jmp parse_number

check_operator:
    # Operators and execution of corresponding operations
    cmp $'+',%al
    je perform_addition
    cmp $'-',%al
    je perform_subtraction
    cmp $'*',%al
    je perform_multiplication
    cmp $'&',%al
    je perform_and_operation
    cmp $'|',%al
    je perform_or_operation
    cmp $'^',%al
    je perform_xor_operation 
    jmp increment_pointer 

# Add
perform_addition:
    pop %r9
    pop %rbx
    movq %rsi, %r12 # Store the address of %rsi 
    # Convert %r9 to binary and print
    mov %r9, %rdi                   # Move %r9 to %rdi for conversion
    lea output_buffer(%rip), %rsi   # Address of output buffer to %rsi
    call decimal_to_binary_12bit    # Convert %rbx to binary
    call print_binary               # Print the binary of %rbx
    call print_addi1

    # Convert %rbx to binary and print
    mov %rbx, %rdi                  # Move %rbx to %rdi for conversion
    lea output_buffer(%rip), %rsi   # Reset %rsi to output buffer
    call decimal_to_binary_12bit    # Convert %rbx to binary
    call print_binary               # Print the binary of %rbx
    call print_addi2

    add %rbx, %r9
    mov $add_op,%rsi
    mov $1, %eax              # Syscall number for sys_write
    mov $1, %edi              # File descriptor 1 (stdout)
    mov $38, %edx
    syscall
    push %r9 
    movq %r12,%rsi            # Restore the input buffer address to %rsi
    jmp increment_pointer

# Subtract
perform_subtraction:
    pop %r9
    pop %rbx
    movq %rsi,%r12 # Store the address of %rsi
    # Convert %r9 to binary and print
    mov %r9, %rdi                  # Move %r9 to %rdi for conversion
    lea output_buffer(%rip), %rsi   # Address of output buffer to %rsi
    call decimal_to_binary_12bit    # Convert %r9 to binary
    call print_binary               # Print the binary of %r9
    call print_addi1

    # Convert %rbx to binary and print
    mov %rbx, %rdi                   # Move %rbx to %rdi for conversion
    lea output_buffer(%rip), %rsi   # Reset %rsi to output buffer
    call decimal_to_binary_12bit    # Convert %rbx to binary
    call print_binary               # Print the binary of %rbx
    call print_addi2

    sub %r9, %rbx
    mov $sub_op,%rsi
    mov $1, %eax              # syscall number for sys_write
    mov $1, %edi              # file descriptor 1 (stdout)
    mov $38, %edx
    syscall
    push %rbx
    movq %r12,%rsi            # Restore the input buffer address to %rsi
    jmp increment_pointer

# Multiply
perform_multiplication:
    pop %r9
    pop %rbx
    movq %rsi,%r12 # Store the address of %rsi
        # Convert %r9 to binary and print
    mov %r9, %rdi                  # Move %r9 to %rdi for conversion
    lea output_buffer(%rip), %rsi   # Address of output buffer to %rsi
    call decimal_to_binary_12bit    # Convert %r9 to binary
    call print_binary               # Print the binary of %r9
    call print_addi1

    # Convert %r9 to binary and print
    mov %rbx, %rdi                   # Move %rbx to %rdi for conversion
    lea output_buffer(%rip), %rsi   # Reset %rsi to output buffer
    call decimal_to_binary_12bit    # Convert %rbx to binary
    call print_binary               # Print the binary of %rbx
    call print_addi2

    imul %r9, %rbx
    mov $mul_op,%rsi
    mov $1, %eax              # Syscall number for sys_write
    mov $1, %edi              # File descriptor 1 (stdout)
    mov $38, %edx
    syscall
    push %rbx
    movq %r12,%rsi            # Restore the input buffer address to %rsi
    jmp increment_pointer

# And
perform_and_operation:
    pop %r9
    pop %rbx
    movq %rsi,%r12 # Store the address of %rsi
    # Convert %r9 to binary and print
    mov %r9, %rdi                  # Move %r9 to %rdi for conversion
    lea output_buffer(%rip), %rsi   # Address of output buffer to %rsi
    call decimal_to_binary_12bit    # Convert %r9 to binary
    call print_binary               # Print the binary of %r9
    call print_addi1

    # Convert %rbx to binary and print
    mov %rbx, %rdi                  # Move %rbx to %rdi for conversion
    lea output_buffer(%rip), %rsi   # Reset %rsi to output buffer
    call decimal_to_binary_12bit    # Convert %rbx to binary
    call print_binary               # Print the binary of %rbx
    call print_addi2

    and %r9, %rbx
    mov $and_op,%rsi
    mov $1, %eax              # Syscall number for sys_write
    mov $1, %edi              # File descriptor 1 (stdout)
    mov $38, %edx
    syscall
    push %rbx
    movq %r12,%rsi            # Restore the input buffer address to %rsi
    jmp increment_pointer

# Or
perform_or_operation:
    pop %r9
    pop %rbx
    movq %rsi,%r12 # Store the address of %rsi
    # Convert %r9 to binary and print
    mov %r9, %rdi                   # Move %r9 to %rdi for conversion
    lea output_buffer(%rip), %rsi   # Address of output buffer to %rsi
    call decimal_to_binary_12bit    # Convert %r9 to binary
    call print_binary               # Print the binary of %r9
    call print_addi1

    # Convert %rbx to binary and print
    mov %rbx, %rdi                  # Move %rbx to %rdi for conversion
    lea output_buffer(%rip), %rsi   # Reset %rsi to output buffer
    call decimal_to_binary_12bit    # Convert %rbx to binary
    call print_binary               # Print the binary of %rbx
    call print_addi2

    or %r9, %rbx
    mov $or_op,%rsi
    mov $1, %eax              # Syscall number for sys_write
    mov $1, %edi              # File descriptor 1 (stdout)
    mov $38, %edx
    syscall
    push %rbx
    movq %r12,%rsi            # Restore the input buffer address to %rsi
    jmp increment_pointer

# Xor
perform_xor_operation:
    pop %r9
    pop %rbx
    movq %rsi,%r12 # Store the address of %rsi
    # Convert %r9 to binary and print
    mov %r9, %rdi                   # Move %r9 to %rdi for conversion
    lea output_buffer(%rip), %rsi   # Address of output buffer to %rsi
    call decimal_to_binary_12bit    # Convert %r9 to binary
    call print_binary               # Print the binary of %r9
    call print_addi1

    # Convert %rbx to binary and print
    mov %rbx, %rdi                  # Move %rbx to %rdi for conversion
    lea output_buffer(%rip), %rsi   # Reset %rsi to output buffer
    call decimal_to_binary_12bit    # Convert %rbx to binary
    call print_binary               # Print the binary of %rbx
    call print_addi2

    xor %r9, %rbx
    mov $xor_op,%rsi
    mov $1, %eax              # Syscall number for sys_write
    mov $1, %edi              # File descriptor 1 (stdout)
    mov $38, %edx
    syscall
    push %rbx
    movq %r12,%rsi            # Restore the input buffer address to %rsi
    jmp increment_pointer

# Increment %rsi
increment_pointer:
    inc %rsi                        # Move to the next character
    jmp parse_loop

# Parsing the number
parse_number:
    xor %ecx, %ecx                  # Clear %ecx to store the number
    jmp number_loop

number_loop:
    movzx %al, %edx                 # Move byte to %edx, zero-extended
    sub $'0', %edx                  # Convert from ascii to integer
    imul $10, %ecx                  # Multiply current number by 10
    add %edx, %ecx                  # Add new digit
    inc %rsi                        # Increment %rsi to next character
    movb (%rsi), %al                # Load next character
    cmp $' ', %al
    jne number_loop

    # Push the number onto the stack
    push %rcx
    jmp parse_loop

# Convert decimal to binary string
decimal_to_binary_12bit:
    # %rdi holds the value to convert
    # %rsi points to the destination buffer
    mov $0, %ecx                   # Counter for 12 bits
    mov $2048, %r8                 # Start with the most significant bit (2^11)

.convert_loop:
    test %r8, %rdi                 # Equivalent to and'ing %rdi with %r8 but safer
    setnz %al                      # Set %al to 1 if the bit is not zero, otherwise 0
    or $48, %al                    # Convert to ascii
    mov %al, (%rsi)                # Store the result in buffer
    shr %r8                        # Shift to the next lower bit
    inc %rsi                       # Move buffer pointer to next character
    inc %ecx                       # Increment the bit counter
    cmp $12, %ecx                  # Check if 12 bits are processed
    jne .convert_loop              # Continue if not
    ret

# Print the first pop
print_addi1:
    mov $addi_1,%rsi
    mov $1, %eax              # Syscall number for sys_write
    mov $1, %edi              # File descriptor 1 (stdout)
    mov $25, %edx
    syscall
    ret

# Print the second pop
print_addi2:
    mov $addi_2,%rsi
    mov $1, %eax              # Syscall number for sys_write
    mov $1, %edi              # File descriptor 1 (stdout)
    mov $25, %edx
    syscall
    ret

# Call to print the binary number buffer
print_binary:
    mov $1, %eax                    # Syscall number for sys_write
    mov $1, %edi                    # File descriptor 1 (stdout)
    lea output_buffer(%rip), %rsi   # Address of the output_buffer
    mov $12, %edx                   # Length of binary string
    syscall                         # Perform the syscall
    ret

exit_program:
    # Exit the program
    mov $60, %eax               # Syscall number for sys_exit
    xor %edi, %edi              # Exit code 0
    syscall
