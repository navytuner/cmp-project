        shift_sp 1
        push_const EXIT
        push_reg fp
        push_reg sp
        pop_reg fp
        jump main
EXIT:
        exit
main:
        shift_sp 20
main_start:
        push_reg fp
        push_const 11
        add
        push_reg sp
        fetch
        push_const 1
        assign
        fetch
        shift_sp -1
        push_reg fp
        push_const 11
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
        push_const 11
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
        push_const 11
        add
        push_const 3
        add
        push_const 0
        add
        push_reg sp
        fetch
        push_const 4
        assign
        fetch
        shift_sp -1
        push_reg fp
        push_const 11
        add
        push_const 3
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
        push_const 11
        add
        push_const 3
        add
        push_const 2
        add
        push_reg sp
        fetch
        push_const 6
        assign
        fetch
        shift_sp -1
        push_reg fp
        push_const 11
        add
        push_const 6
        add
        push_const 0
        push_const 2
        mul
        add
        push_reg sp
        fetch
        push_const 7
        assign
        fetch
        shift_sp -1
        push_reg fp
        push_const 11
        add
        push_const 6
        add
        push_const 0
        push_const 2
        mul
        add
        push_const 1
        add
        push_reg sp
        fetch
        push_const 8
        assign
        fetch
        shift_sp -1
        push_reg fp
        push_const 11
        add
        push_const 6
        add
        push_const 1
        push_const 2
        mul
        add
        push_reg sp
        fetch
        push_const 9
        assign
        fetch
        shift_sp -1
        push_reg fp
        push_const 11
        add
        push_const 6
        add
        push_const 1
        push_const 2
        mul
        add
        push_const 1
        add
        push_reg sp
        fetch
        push_const 10
        assign
        fetch
        shift_sp -1
        push_reg fp
        push_const 1
        add
        push_reg sp
        fetch
        push_reg sp
        fetch
        push_const 1
        add
        push_reg sp
        fetch
        push_const 1
        add
        push_reg sp
        fetch
        push_const 1
        add
        push_reg sp
        fetch
        push_const 1
        add
        push_reg sp
        fetch
        push_const 1
        add
        push_reg sp
        fetch
        push_const 1
        add
        push_reg sp
        fetch
        push_const 1
        add
        push_reg sp
        fetch
        push_const 1
        add
        push_reg sp
        fetch
        push_const 1
        add
        push_reg fp
        push_const 11
        add
        fetch
        shift_sp -1
        push_reg fp
        push_const 11
        add
        push_const 9
        add
        fetch
        assign
        push_reg fp
        push_const 11
        add
        push_const 8
        add
        fetch
        assign
        push_reg fp
        push_const 11
        add
        push_const 7
        add
        fetch
        assign
        push_reg fp
        push_const 11
        add
        push_const 6
        add
        fetch
        assign
        push_reg fp
        push_const 11
        add
        push_const 5
        add
        fetch
        assign
        push_reg fp
        push_const 11
        add
        push_const 4
        add
        fetch
        assign
        push_reg fp
        push_const 11
        add
        push_const 3
        add
        fetch
        assign
        push_reg fp
        push_const 11
        add
        push_const 2
        add
        fetch
        assign
        push_reg fp
        push_const 11
        add
        push_const 1
        add
        fetch
        assign
        push_reg fp
        push_const 11
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
        push_reg fp
        push_const 1
        add
        push_const 3
        add
        push_const 0
        add
        fetch
        write_int
        push_reg fp
        push_const 1
        add
        push_const 3
        add
        push_const 1
        add
        fetch
        write_int
        push_reg fp
        push_const 1
        add
        push_const 3
        add
        push_const 2
        add
        fetch
        write_int
        push_reg fp
        push_const 1
        add
        push_const 6
        add
        push_const 0
        push_const 2
        mul
        add
        fetch
        write_int
        push_reg fp
        push_const 1
        add
        push_const 6
        add
        push_const 0
        push_const 2
        mul
        add
        push_const 1
        add
        fetch
        write_int
        push_reg fp
        push_const 1
        add
        push_const 6
        add
        push_const 1
        push_const 2
        mul
        add
        fetch
        write_int
        push_reg fp
        push_const 1
        add
        push_const 6
        add
        push_const 1
        push_const 2
        mul
        add
        push_const 1
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
main_end:
Lglob.  data 0
