	.text
	.attribute	4, 16
	.attribute	5, "rv32i2p1_m2p0_a2p1_f2p2_d2p2_zicsr2p0_zifencei2p0"
	.file	"calculadora.c"
	.globl	exit                            # -- Begin function exit
	.p2align	2
	.type	exit,@function
exit:                                   # @exit
# %bb.0:
	addi	sp, sp, -16
	sw	ra, 12(sp)                      # 4-byte Folded Spill
	sw	s0, 8(sp)                       # 4-byte Folded Spill
	addi	s0, sp, 16
	sw	a0, -12(s0)
	lw	a1, -12(s0)
	#APP
	mv	a0, a1	# return code
	li	a7, 93	# syscall exit (64) 
	ecall
	#NO_APP
.Lfunc_end0:
	.size	exit, .Lfunc_end0-exit
                                        # -- End function
	.globl	_start                          # -- Begin function _start
	.p2align	2
	.type	_start,@function
_start:                                 # @_start
# %bb.0:
	addi	sp, sp, -16
	sw	ra, 12(sp)                      # 4-byte Folded Spill
	sw	s0, 8(sp)                       # 4-byte Folded Spill
	addi	s0, sp, 16
	call	main
	sw	a0, -12(s0)
	lw	a0, -12(s0)
	call	exit
.Lfunc_end1:
	.size	_start, .Lfunc_end1-_start
                                        # -- End function
	.globl	read                            # -- Begin function read
	.p2align	2
	.type	read,@function
read:                                   # @read
# %bb.0:
	addi	sp, sp, -32
	sw	ra, 28(sp)                      # 4-byte Folded Spill
	sw	s0, 24(sp)                      # 4-byte Folded Spill
	addi	s0, sp, 32
	sw	a0, -12(s0)
	sw	a1, -16(s0)
	sw	a2, -20(s0)
	lw	a3, -12(s0)
	lw	a4, -16(s0)
	lw	a5, -20(s0)
	#APP
	mv	a0, a3	# file descriptor
	mv	a1, a4	# buffer 
	mv	a2, a5	# size 
	li	a7, 63	# syscall read code (63) 
	ecall	# invoke syscall 
	mv	a3, a0	# move return value to ret_val

	#NO_APP
	sw	a3, -28(s0)                     # 4-byte Folded Spill
	lw	a0, -28(s0)                     # 4-byte Folded Reload
	sw	a0, -24(s0)
	lw	a0, -24(s0)
	lw	ra, 28(sp)                      # 4-byte Folded Reload
	lw	s0, 24(sp)                      # 4-byte Folded Reload
	addi	sp, sp, 32
	ret
.Lfunc_end2:
	.size	read, .Lfunc_end2-read
                                        # -- End function
	.globl	write                           # -- Begin function write
	.p2align	2
	.type	write,@function
write:                                  # @write
# %bb.0:
	addi	sp, sp, -32
	sw	ra, 28(sp)                      # 4-byte Folded Spill
	sw	s0, 24(sp)                      # 4-byte Folded Spill
	addi	s0, sp, 32
	sw	a0, -12(s0)
	sw	a1, -16(s0)
	sw	a2, -20(s0)
	lw	a3, -12(s0)
	lw	a4, -16(s0)
	lw	a5, -20(s0)
	#APP
	mv	a0, a3	# file descriptor
	mv	a1, a4	# buffer 
	mv	a2, a5	# size 
	li	a7, 64	# syscall write (64) 
	ecall
	#NO_APP
	lw	ra, 28(sp)                      # 4-byte Folded Reload
	lw	s0, 24(sp)                      # 4-byte Folded Reload
	addi	sp, sp, 32
	ret
.Lfunc_end3:
	.size	write, .Lfunc_end3-write
                                        # -- End function
	.globl	main                            # -- Begin function main
	.p2align	2
	.type	main,@function
main:                                   # @main
# %bb.0:
	addi	sp, sp, -48
	sw	ra, 44(sp)                      # 4-byte Folded Spill
	sw	s0, 40(sp)                      # 4-byte Folded Spill
	addi	s0, sp, 48
	li	a0, 0
	sw	a0, -12(s0)
	lui	a1, %hi(input_buffer)
	sw	a1, -44(s0)                     # 4-byte Folded Spill
	addi	a1, a1, %lo(input_buffer)
	sw	a1, -40(s0)                     # 4-byte Folded Spill
	li	a2, 5
	call	read
	lw	a1, -44(s0)                     # 4-byte Folded Reload
	mv	a2, a0
	lw	a0, -40(s0)                     # 4-byte Folded Reload
	sw	a2, -16(s0)
	lbu	a1, %lo(input_buffer)(a1)
	sb	a1, -17(s0)
	lbu	a1, 4(a0)
	sb	a1, -18(s0)
	lbu	a0, 2(a0)
	sb	a0, -19(s0)
	lbu	a0, -17(s0)
	addi	a0, a0, -48
	sw	a0, -24(s0)
	lbu	a0, -18(s0)
	addi	a0, a0, -48
	sw	a0, -28(s0)
	lbu	a0, -19(s0)
	li	a1, 43
	bne	a0, a1, .LBB4_2
	j	.LBB4_1
.LBB4_1:
	lw	a0, -24(s0)
	lw	a1, -28(s0)
	add	a0, a0, a1
	sw	a0, -32(s0)
	j	.LBB4_6
.LBB4_2:
	lbu	a0, -19(s0)
	li	a1, 45
	bne	a0, a1, .LBB4_4
	j	.LBB4_3
.LBB4_3:
	lw	a0, -24(s0)
	lw	a1, -28(s0)
	sub	a0, a0, a1
	sw	a0, -32(s0)
	j	.LBB4_5
.LBB4_4:
	lw	a0, -24(s0)
	lw	a1, -28(s0)
	mul	a0, a0, a1
	sw	a0, -32(s0)
	j	.LBB4_5
.LBB4_5:
	j	.LBB4_6
.LBB4_6:
	lw	a0, -32(s0)
	addi	a0, a0, 48
	sb	a0, -34(s0)
	li	a0, 10
	sb	a0, -33(s0)
	li	a0, 1
	addi	a1, s0, -34
	li	a2, 2
	call	write
	li	a0, 0
	lw	ra, 44(sp)                      # 4-byte Folded Reload
	lw	s0, 40(sp)                      # 4-byte Folded Reload
	addi	sp, sp, 48
	ret
.Lfunc_end4:
	.size	main, .Lfunc_end4-main
                                        # -- End function
	.type	input_buffer,@object            # @input_buffer
	.section	.sbss,"aw",@nobits
	.globl	input_buffer
input_buffer:
	.zero	6
	.size	input_buffer, 6

	.ident	"clang version 17.0.6 (Fedora 17.0.6-2.fc39)"
	.section	".note.GNU-stack","",@progbits
	.addrsig
	.addrsig_sym exit
	.addrsig_sym read
	.addrsig_sym write
	.addrsig_sym main
	.addrsig_sym input_buffer
