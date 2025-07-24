    section .text
    global _start


    _start:
        call input_data
        call output_data

        mov rax, 60
        mov rdi, 0
        syscall

    input_data:
        mov rax , 1
        mov rdi, 1
        mov rsi, initial_message
        mov rdx, initial_message_len
        syscall

        mov rax, 0
        mov rdi, 0
        mov rsi, input_buffer
        mov rdx, 128
        syscall

        mov rsi, input_buffer
        mov rdi, int_array
        mov rcx, 0
        mov rbx, 0         ; Index for int_array

        parse_loop:
            mov al, [rsi]

            cmp al, 0
            je store_last_number
            cmp al, 32
            je skip_space
            cmp al, 10
            je store_last_number


            cmp al, 44
            je store_integer

            sub al, '0'
            imul rcx, rcx, 10
            movzx rax, al
            add rcx, rax
        skip_space:
            inc rsi
            jmp parse_loop


        store_integer:
            mov [rdi+rbx*4], ecx
            inc rbx
            inc rsi
            xor rcx, rcx
            cmp rbx, 5
            jge parse_end
            jmp parse_loop

        store_last_number:
            cmp rbx, 5
            jge parse_end
            mov [rdi+rbx*4], ecx
            inc rbx

        parse_end:
            ret 

    output_data:
        mov r12, 0
        
        print_loop:
            cmp r12, 5
            jge print_end

            mov rsi, output_buffer
            mov eax, [int_array + r12*4]
            xor r10, r10

            mov r9, rsi

            test eax, eax
            jnz convert_digits
            mov byte [rsi], '0'
            inc r10
            jmp print_ascii
        
        convert_digits:
        
        convert_loop:
            xor rdx, rdx
            mov rbx, 10
            div rbx
            add dl, '0'
            mov [rsi], dl
            inc rsi
            inc r10
            test eax, eax
            jnz convert_loop

            mov rsi, r9
            mov rdi, r9
            add rdi, r10
            dec rdi
        
        reverse_loop:
            cmp rsi, rdi
            jge print_ascii
            mov al, [rsi]
            mov bl, [rdi]
            mov [rsi], bl
            mov [rdi], al
            inc rsi
            dec rdi
            jmp reverse_loop
        
        print_ascii:
            mov rsi, r9
            add rsi, r10
            mov byte [rsi], 10
            inc r10

            mov rax, 1
            mov rdi, 1
            mov rdx, r10
            mov rsi, r9
            syscall


            inc r12
            jmp print_loop

        print_end:
            ret
    

    section .data
        initial_message db "Enter 5 integers(with comma): ", 0
        initial_message_len equ $ - initial_message

    section .bss
        int_array resd 5
        input_buffer resb 128
        output_buffer resb 128