        shift_sp 1
        push_const EXIT
        push_reg fp
        push_reg sp
        pop_reg fp
        jump main
EXIT:
        exit
make_vec:
        shift_sp 2
make_vec_start:
        push_reg fp
        push_const 3
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
        push_const 3
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
        push_const -1
        add
        push_const -1
        add
        push_reg fp
        push_const 3
        add
        assign
        push_reg fp
        push_const -3
        add
        fetch
        push_reg fp
        push_const 4
        add
        fetch
        assign
        push_reg fp
        push_const -4
        add
        fetch
        push_reg fp
        push_const 3
        add
        fetch
        assign
        jump make_vec_final
make_vec_final:
        push_reg fp
        pop_reg sp
        pop_reg fp
        pop_reg pc
make_vec_end:
sum_components:
sum_components_start:
        push_reg fp
        push_const -1
        add
        push_const -1
        add
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
        add
        assign
        jump sum_components_final
sum_components_final:
        push_reg fp
        pop_reg sp
        pop_reg fp
        pop_reg pc
sum_components_end:
add_vec:
        shift_sp 2
add_vec_start:
        push_reg fp
        push_const 5
        add
        push_reg sp
        fetch
        push_reg fp
        push_const 1
        add
        fetch
        push_reg fp
        push_const 3
        add
        fetch
        add
        assign
        fetch
        shift_sp -1
        push_reg fp
        push_const 5
        add
        push_const 1
        add
        push_reg sp
        fetch
        push_reg fp
        push_const 1
        add
        push_const 1
        add
        fetch
        push_reg fp
        push_const 3
        add
        push_const 1
        add
        fetch
        add
        assign
        fetch
        shift_sp -1
        push_reg fp
        push_const -1
        add
        push_const -1
        add
        push_reg fp
        push_const 5
        add
        assign
        push_reg fp
        push_const -3
        add
        fetch
        push_reg fp
        push_const 6
        add
        fetch
        assign
        push_reg fp
        push_const -4
        add
        fetch
        push_reg fp
        push_const 5
        add
        fetch
        assign
        jump add_vec_final
add_vec_final:
        push_reg fp
        pop_reg sp
        pop_reg fp
        pop_reg pc
add_vec_end:
main:
        shift_sp 19
main_start:
        push_reg fp
        push_const 1
        add
        push_reg sp
        fetch
        push_reg sp
        fetch
        push_const 1
        add
        shift_sp 1
        push_const label_0
        push_reg fp
        push_const 2
        push_const 5
        push_reg sp
        push_const -2
        add
        pop_reg fp
        jump make_vec
label_0:
        fetch
        shift_sp -1
        push_reg fp
        push_const 3
        add
        push_reg sp
        fetch
        push_reg sp
        fetch
        push_const 1
        add
        push_reg fp
        push_const 1
        add
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
        push_reg fp
        push_const 5
        add
        push_reg sp
        fetch
        push_reg sp
        fetch
        push_const 1
        add
        shift_sp 1
        push_const label_1
        push_reg fp
        push_const 7
        push_const 4
        push_reg sp
        push_const -2
        add
        pop_reg fp
        jump make_vec
label_1:
        fetch
        shift_sp -1
        push_reg fp
        push_const 7
        add
        push_reg sp
        fetch
        push_reg sp
        fetch
        push_const 1
        add
        shift_sp 1
        push_const label_2
        push_reg fp
        push_reg fp
        push_const 3
        add
        shift_sp -1
        push_reg fp
        push_const 3
        add
        fetch
        push_reg fp
        push_const 3
        add
        push_const 1
        add
        fetch
        push_reg fp
        push_const 5
        add
        shift_sp -1
        push_reg fp
        push_const 5
        add
        fetch
        push_reg fp
        push_const 5
        add
        push_const 1
        add
        fetch
        push_reg sp
        push_const -4
        add
        pop_reg fp
        jump add_vec
label_2:
        fetch
        shift_sp -1
        push_reg fp
        push_const 9
        add
        push_reg sp
        fetch
        shift_sp 1
        push_const label_3
        push_reg fp
        push_reg fp
        push_const 7
        add
        shift_sp -1
        push_reg fp
        push_const 7
        add
        fetch
        push_reg fp
        push_const 7
        add
        push_const 1
        add
        fetch
        push_reg sp
        push_const -2
        add
        pop_reg fp
        jump sum_components
label_3:
        assign
        fetch
        shift_sp -1
str_0. string "== Test: Base vector initialization ==\n"
        push_const str_0
        write_string
str_1. string "Result: "
        push_const str_1
        write_string
        push_reg fp
        push_const 1
        add
        fetch
        write_int
str_2. string ", "
        push_const str_2
        write_string
        push_reg fp
        push_const 1
        add
        push_const 1
        add
        fetch
        write_int
str_3. string "\n"
        push_const str_3
        write_string
str_4. string "Ground truth : 2, 5\n\n"
        push_const str_4
        write_string
str_5. string "== Test: Struct assignment copy ==\n"
        push_const str_5
        write_string
str_6. string "Result: "
        push_const str_6
        write_string
        push_reg fp
        push_const 3
        add
        fetch
        write_int
str_7. string ", "
        push_const str_7
        write_string
        push_reg fp
        push_const 3
        add
        push_const 1
        add
        fetch
        write_int
str_8. string "\n"
        push_const str_8
        write_string
str_9. string "Ground truth -> Copy via assignment: 2, 5\n\n"
        push_const str_9
        write_string
str_10. string "== Test: Struct-returning make_vec ==\n"
        push_const str_10
        write_string
str_11. string "Result: "
        push_const str_11
        write_string
        push_reg fp
        push_const 5
        add
        fetch
        write_int
str_12. string ", "
        push_const str_12
        write_string
        push_reg fp
        push_const 5
        add
        push_const 1
        add
        fetch
        write_int
str_13. string "\n"
        push_const str_13
        write_string
str_14. string "Ground truth -> Offset vector: 7, 4\n\n"
        push_const str_14
        write_string
str_15. string "== Test: add_vec parameter passing ==\n"
        push_const str_15
        write_string
str_16. string "Result: "
        push_const str_16
        write_string
        push_reg fp
        push_const 7
        add
        fetch
        write_int
str_17. string ", "
        push_const str_17
        write_string
        push_reg fp
        push_const 7
        add
        push_const 1
        add
        fetch
        write_int
str_18. string "\n"
        push_const str_18
        write_string
str_19. string "Ground truth -> Combined vector: 9, 9\n\n"
        push_const str_19
        write_string
str_20. string "== Test: sum_components parameter passing ==\n"
        push_const str_20
        write_string
str_21. string "Result: "
        push_const str_21
        write_string
        push_reg fp
        push_const 9
        add
        fetch
        write_int
str_22. string "\n"
        push_const str_22
        write_string
str_23. string "Ground truth -> Total sum: 18\n\n"
        push_const str_23
        write_string
        push_reg fp
        push_const 10
        add
        push_reg sp
        fetch
        push_reg sp
        fetch
        push_const 1
        add
        push_reg fp
        push_const 1
        add
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
        push_reg fp
        push_const 10
        add
        push_const 2
        add
        push_const 0
        add
        push_reg sp
        fetch
        push_const 10
        assign
        fetch
        shift_sp -1
        push_reg fp
        push_const 10
        add
        push_const 2
        add
        push_const 1
        add
        push_reg sp
        fetch
        push_const 20
        assign
        fetch
        shift_sp -1
        push_reg fp
        push_const 10
        add
        push_const 2
        add
        push_const 2
        add
        push_reg sp
        fetch
        push_const 30
        assign
        fetch
        shift_sp -1
        push_reg fp
        push_const 15
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
        push_reg fp
        push_const 10
        add
        push_reg sp
        push_const -1
        add
        fetch
        push_reg sp
        push_const -1
        add
        fetch
        push_const 4
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
        push_const 3
        add
        fetch
        assign
        push_reg sp
        push_const -3
        add
        fetch
        push_reg sp
        push_const -1
        add
        fetch
        push_const 2
        add
        fetch
        assign
        push_reg sp
        push_const -4
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
        push_const -5
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
str_24. string "== Test: Nested struct assignment ==\n"
        push_const str_24
        write_string
str_25. string "Result: "
        push_const str_25
        write_string
        push_reg fp
        push_const 15
        add
        fetch
        write_int
str_26. string ", "
        push_const str_26
        write_string
        push_reg fp
        push_const 15
        add
        push_const 1
        add
        fetch
        write_int
str_27. string "\n"
        push_const str_27
        write_string
str_28. string "Ground truth -> Nested struct copy: 2, 5\n\n"
        push_const str_28
        write_string
str_29. string "== Test: Embedded array copy ==\n"
        push_const str_29
        write_string
str_30. string "Result: "
        push_const str_30
        write_string
        push_reg fp
        push_const 15
        add
        push_const 2
        add
        push_const 0
        add
        fetch
        write_int
str_31. string ", "
        push_const str_31
        write_string
        push_reg fp
        push_const 15
        add
        push_const 2
        add
        push_const 1
        add
        fetch
        write_int
str_32. string ", "
        push_const str_32
        write_string
        push_reg fp
        push_const 15
        add
        push_const 2
        add
        push_const 2
        add
        fetch
        write_int
str_33. string "\n"
        push_const str_33
        write_string
str_34. string "Ground truth -> Array copy: 10, 20, 30\n"
        push_const str_34
        write_string
        push_reg fp
        push_const -1
        add
        push_const -1
        add
        push_const 0
        assign
        jump main_final
main_final:
        push_reg fp
        pop_reg sp
        pop_reg fp
        pop_reg pc
main_end:
Lglob.  data 0
