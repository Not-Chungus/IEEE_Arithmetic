#vlib work

vlog ../VS_code/Project/Control_and_Sign.v ../VS_code/Project/FPA_Top.v ../VS_code/Project/last_normalize.v ../VS_code/Project/Pack.v ../VS_code/Project/Post_shifter.v ../VS_code/Project/Pre_shifter.v ../VS_code/Project/Round_sel_complement.v ../VS_code/Project/sub_and_swap.v ../VS_code/Project/Unpack.v ../VS_code/Project/extra_imp_modules/LOC_32bit.v ../VS_code/Project/extra_imp_modules/LZC_32bit.v 

vsim -voptargs=+acc tb_FPA_Top
add wave *
#do wave.do
run -all
#quit -sim