        shift_sp 1
        push_const EXIT
        push_reg fp
        push_reg sp
        pop_reg fp
        jump main
EXIT:
        exit
main:
        shift_sp 6
main_start:
        push_reg fp
        push_const 4
        add
        push_reg sp
        fetch
        push_const 1
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
        push_const 2
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
        push_const 3
        assign
        fetch
        shift_sp -1
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
        push_reg fp
        push_const 4
        add
        fetch
        shift_sp -1
        push_reg fp
        push_const 4
        add
        push_const 2
        add
        fetch
        assign
        push_reg fp
        push_const 4
        add
        push_const 1
        add
        fetch
        assign
        push_reg fp
        push_const 4
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
main_final:
        push_reg fp
        pop_reg sp
        pop_reg fp
        pop_reg pc
main_end:
Lglob.  data 0
