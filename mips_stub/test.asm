# Test load words and store words
main: addi $sp, $zero, 300
 	nop
	lw	$t0, 0($zero)
	sw	$t0, 0($sp)
	lw	$t1, 4($zero)
	sw	$t1, 4($sp)
	lw	$t2, 8($zero)
	sw	$t2, 8($sp)
 

	# Test R-type instructions
	addi $t3, $zero, 3
	addi $t4, $zero, 7
	and $s0, $t3, $t4
	sw $s0, 12($sp) # out = 3
	or $s1, $t3, $t4
	sw $s1, 16($sp) # out = 7
	add $s2, $t3, $t4
	sw $s2, 20($sp) # out = 10

	# I-type instructions
	ori $s7, $s2, 5
	sw $s7, 24($sp) # out = f

	xori $s7, $s2, 5
	sw $s7, 28($sp) # out = f

	andi $s7, $s2, 5
	sw $s7, 32($sp) # out = 0

	slti $s7, $s2, 5
	sw $s7, 36($sp) # out = 0

	slti $s7, $s2, 15
	sw $s7, 40($sp) # out = 1

	# Test branches
	beq $s0, $s0, finish

dest1: nor $s5, $t3, $t4
   sw $s5, 60($sp) # out = something crazy
	# Jump to the finish
   j finish2

dest2: sub $s3, $t4, $t3
	sw $s3, 44($sp) # out = 4
	xor $s4, $t3, $t4
	sw $s4, 48($sp) # out = 4
	sw $ra, 52($sp) # out = the return adddress
	jr $ra

finish: jal dest2
	addi $t3, $zero, 8
	addi $t4, $zero, 8
	and $s0, $t3, $t4
	sw $s0, 56($sp) # out = 8
	bne $s1, $s0, dest1

finish2: addi $t0, $zero, 32
       sll $t1, $t0, 2
       sw $t1, 64($sp) # out = 128
       srl $t2, $t0, 2
       sw $t2, 68($sp) # out = 8
       sra $t3, $t0, 2
       sw $t3, 72($sp) # out = 8
