section .text
global _start


_start:
    call input_data
    mov rdi, int_array
    mov r9, 0
    mov r11, 4
    call merge_sort
    call output_data

    mov rax, 60
    mov rdi, 0
    syscall

merge_sort:
    ; rdi = address of array
    ; r9 = left index
    ; r11 = right index
    cmp r9, r11
    jge mergesort_done
    mov rcx, r9
    add rcx, r11
    shr rcx, 1

    push rcx
    push rdi
    push r9
    push r11

    mov r9, r9
    mov r11, rcx
    call merge_sort

    pop r11
    pop r9
    pop rdi
    pop rcx

    push rcx
    push rdi
    push r9
    push r11

    mov r9, rcx
    inc r9
    mov r11, r11
    call merge_sort

    pop r11
    pop r9
    pop rdi
    pop rcx

    mov r8, rdi
    mov r9, r9
    mov r10, rcx
    mov r11, r11
    call merge

mergesort_done:
    ret



merge:
    ; r8 = array address
    ; r9 = left
    ; r10 = mid
    ; r11 = right
    mov rax, r11
    sub rax, r9
    inc rax
    imul rax, 4
    sub rsp, rax

    mov r12, r9
    mov r13, r10
    inc r13
    mov r14, 0
merge_loop:
    cmp r12, r10
    jg right_part
    cmp r13, r11
    jg left_part

    mov eax, [r8+r12*4]
    mov ebx, [r8+r13*4]
    cmp eax, ebx
    jle copy_left
    mov [rsp+r14*4], ebx
    inc r13
    jmp inc_k
copy_left:
    mov [rsp+r14*4], eax
    inc r12
inc_k:
    inc r14
    jmp merge_loop


left_part:
    cmp r12, r10
    jg copy_temp
    mov eax, [r8+r12*4]
    mov [rsp+r14*4], eax
    inc r12
    inc r14
    jmp left_part
right_part:
    cmp r13, r11
    jg copy_temp
    mov eax, [r8+r13*4]
    mov [rsp+r14*4], eax
    inc r13
    inc r14
    jmp right_part
copy_temp:
    mov r15, 0
copy_loop:
    cmp r15, r14
    jge merge_done
    mov eax, [rsp+r15*4]
    mov rbx, r9
    add rbx, r15
    mov [r8+rbx*4], eax
    inc r15
    jmp copy_loop
merge_done:
    mov rax, r11
    sub rax, r9
    inc rax
    imul rax, 4
    add rsp, rax
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