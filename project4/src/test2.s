        shift_sp 1
        push_const EXIT
        push_reg fp
        push_reg sp
        pop_reg fp
        jump main
EXIT:
        exit
main:
        shift_sp 3
main_start:
        push_reg fp
        push_const 3
        add
        push_reg sp
        fetch
        push_const 0
        assign
        fetch
        shift_sp -1
        push_reg fp
        push_const 1
        add
        push_reg sp
        fetch
        push_const 0
        assign
        fetch
        shift_sp -1
label_0:
        push_reg fp
        push_const 1
        add
        fetch
        push_const 3
        less
        branch_false label_3
        jump label_2
label_1:
        push_reg fp
        push_const 1
        add
        push_reg sp
        fetch
        push_reg sp
        fetch
        fetch
        push_const 1
        add
        assign
        fetch
        push_const 1
        sub
        jump label_0
label_2:
        push_reg fp
        push_const 1
        add
        fetch
        write_int
str_0. string "\n"
        push_const str_0
        write_string
        push_reg fp
        push_const 2
        add
        push_reg sp
        fetch
        push_const 0
        assign
        fetch
        shift_sp -1
label_4:
        push_reg fp
        push_const 2
        add
        fetch
        push_const 5
        less
        branch_false label_7
        jump label_6
label_5:
        push_reg fp
        push_const 2
        add
        push_reg sp
        fetch
        push_reg sp
        fetch
        fetch
        push_const 1
        add
        assign
        fetch
        push_const 1
        sub
        jump label_4
label_6:
        push_reg fp
        push_const 2
        add
        fetch
        push_const 1
        equal
        branch_false label_8
        jump label_7
label_8:
        push_reg fp
        push_const 2
        add
        fetch
        write_int
        push_const 32
        write_char
        jump label_5
label_7:
str_1. string "\n"
        push_const str_1
        write_string
        push_reg fp
        push_const 1
        add
        fetch
        push_const 1
        equal
        branch_false label_10
        jump label_1
label_10:
        jump label_1
label_3:
str_2. string "\n"
        push_const str_2
        write_string
main_final:
        push_reg fp
        pop_reg sp
        pop_reg fp
        pop_reg pc
main_end:
Lglob.  data 0
