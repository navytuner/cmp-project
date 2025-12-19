        shift_sp 2
        push_const EXIT
        push_reg fp
        push_reg sp
        pop_reg fp
        jump main
EXIT:
        exit
func:
        shift_sp 3
func_start:
        push_reg fp
        push_const 4
        add
        push_reg sp
        fetch
        push_reg fp
        push_const 1
        add
        fetch
        assign
        fetch
        shift_sp -1
        push_reg fp
        push_const 4
        add
        push_const 1
        add
        push_reg sp
        fetch
        push_reg fp
        push_const 2
        add
        fetch
        assign
        fetch
        shift_sp -1
        push_reg fp
        push_const 4
        add
        push_const 2
        add
        push_reg sp
        fetch
        push_reg fp
        push_const 3
        add
        fetch
        assign
        fetch
        shift_sp -1
main:
        shift_sp 3
main_start:
        push_reg fp
        push_const 1
        add
        push_reg fp
        push_const 1
        add
        push_reg fp
        push_const 1
        add
        push_const 1
        add
        push_reg fp
        push_const 1
        add
        push_const 2
        add
        shift_sp 2
        push_const label_0
        push_reg fp
        push_const 1
        push_const 2
        push_const 3
        push_reg sp
        push_const -3
        add
        pop_reg fp
        jump func
label_0:
        shift_sp -1
        push_reg fp
        push_const 1
        add
        push_const 2
        add
        fetch
        assign
        push_reg fp
        push_const 1
        add
        push_const 1
        add
        fetch
        assign
        push_reg fp
        push_const 1
        add
        fetch
        assign
        push_reg fp
        push_const 1
        add
        fetch
        write_int
        push_reg fp
        push_const 1
        add
        push_const 1
        add
        fetch
        write_int
        push_reg fp
        push_const 1
        add
        push_const 2
        add
        fetch
        write_int
str_0. string "\n"
        push_const str_0
        write_string
main_final:
        push_reg fp
        pop_reg sp
        pop_reg fp
        pop_reg pc
        shift_sp -1
main_end:
Lglob.  data 0
