        shift_sp 1
        push_const EXIT
        push_reg fp
        push_reg sp
        pop_reg fp
        jump main
EXIT:
        exit
main:
main_start:
        push_const Lglob+0
        push_reg sp
        fetch
        push_const 1
        assign
        fetch
        shift_sp -1
        push_const Lglob+0
        push_const 1
        add
        push_reg sp
        fetch
        push_const 2
        assign
        fetch
        shift_sp -1
        push_const Lglob+2
        push_reg sp
        fetch
        push_const Lglob+3
        assign
        fetch
        shift_sp -1
        push_const Lglob+2
        fetch
        push_reg sp
        fetch
        push_reg sp
        fetch
        push_const 1
        add
        push_const Lglob+0
        push_reg sp
        push_const -1
        add
        fetch
        push_reg sp
        push_const -1
        add
        fetch
        push_const 1
        add
        fetch
        assign
        push_reg sp
        push_const -2
        add
        fetch
        push_reg sp
        push_const -1
        add
        fetch
        fetch
        assign
        fetch
        shift_sp -1
        push_const Lglob+2
        fetch
        fetch
        write_int
        push_const Lglob+2
        fetch
        push_const 1
        add
        fetch
        write_int
main_final:
        push_reg fp
        pop_reg sp
        pop_reg fp
        pop_reg pc
main_end:
Lglob.  data 5
