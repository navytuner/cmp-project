        shift_sp 1
        push_const EXIT
        push_reg fp
        push_reg sp
        pop_reg fp
        jump main
EXIT:
        exit
func:
func_start:
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
        push_reg fp
        push_const 4
        add
        fetch
        write_int
        push_reg fp
        push_const 4
        add
        push_const 1
        add
        fetch
        write_int
        push_reg fp
        push_const 4
        add
        push_const 2
        add
        fetch
        write_int
str_0. string "\n"
        push_const str_0
        write_string
func_final:
        push_reg fp
        pop_reg sp
        pop_reg fp
        pop_reg pc
func_end:
main:
        shift_sp 6
main_start:
        push_reg fp
        push_const 1
        add
        push_reg sp
        fetch
        push_const 1
        assign
        fetch
        shift_sp -1
        push_reg fp
        push_const 1
        add
        push_const 1
        add
        push_reg sp
        fetch
        push_const 2
        assign
        fetch
        shift_sp -1
        push_reg fp
        push_const 1
        add
        push_const 2
        add
        push_reg sp
        fetch
        push_const 3
        assign
        fetch
        shift_sp -1
        push_reg fp
        push_const 4
        add
        push_reg sp
        fetch
        push_const 4
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
        push_const 5
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
        push_const 6
        assign
        fetch
        shift_sp -1
        shift_sp 1
        push_const label_0
        push_reg fp
        push_reg fp
        push_const 1
        add
        fetch
        shift_sp -1
        push_reg fp
        push_const 1
        add
        fetch
        push_reg fp
        push_const 1
        add
        push_const 1
        add
        fetch
        push_reg fp
        push_const 1
        add
        push_const 2
        add
        fetch
        push_reg fp
        push_const 4
        add
        fetch
        shift_sp -1
        push_reg fp
        push_const 4
        add
        fetch
        push_reg fp
        push_const 4
        add
        push_const 1
        add
        fetch
        push_reg fp
        push_const 4
        add
        push_const 2
        add
        fetch
        push_reg sp
        push_const -6
        add
        pop_reg fp
        jump func
label_0:
main_final:
        push_reg fp
        pop_reg sp
        pop_reg fp
        pop_reg pc
main_end:
Lglob.  data 0
