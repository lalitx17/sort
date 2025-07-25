section .text
global _start


_start:
    call input_data
    call heap_sort
    call output_data

    mov rax, 60
    mov rdi, 0
    syscall

heap_sort:
    ; rdi = int_array
    ; rsi = n (size of the array)
    mov rdi, int_array
    mov rsi, 5
    mov rcx, rsi
    shr rcx, 2
    dec rcx
build_heap:
    cmp rcx, -1
    jl extract_heap
    mov rdx, rcx
    push rcx
    call heapify
    pop rcx
    dec rcx
    jmp build_heap
extract_heap:
    mov rcx, rsi
    dec rcx
extract_loop:
    cmp rcx, 0
    jle sort_done;
    mov eax, [rdi]
    mov ebx, [rdi+rcx*4]
    mov [rdi], ebx
    mov [rdi+rcx*4], eax
    mov rsi, rcx
    mov rdx, 0
    call heapify
    dec rcx
    jmp extract_loop
sort_done:
    ret

heapify:
    ; rdi = int_array
    ; rsi = n (size of the array)
    ; rdx = i (index of the element to heapify)
    push r8
    push r9
    push r10
    mov r8, rdx
    mov r9, rdx
    shl r9, 1
    inc r9
    mov r10, rdx
    shl r10, 1
    add r10, 2

compare_left:
    cmp r9, rsi
    jge compare_right
    mov eax, [rdi + r9*4]
    mov ebx, [rdi + r8*4]
    cmp eax, ebx
    jle compare_right
    mov r8, r9

compare_right:
    cmp r10, rsi
    jge compare_done
    mov eax, [rdi + r10*4]
    mov ebx, [rdi + r8*4]
    cmp eax, ebx
    jle compare_done
    mov r8, r10
compare_done:
    cmp r8, rdx
    je heapify_end
    mov eax, [rdi + rdx*4]
    mov ebx, [rdi + r8*4]
    mov [rdi + rdx*4], ebx
    mov [rdi + r8*4], eax
    mov rdx, r8
    call heapify
heapify_end:
    pop r10
    pop r9
    pop r8
    ret



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