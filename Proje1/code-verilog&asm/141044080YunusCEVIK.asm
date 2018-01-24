# 14104080 YUNUS CEVIK

.data
stringBuf: .space 255    # Kullanicidan girilen stringin tutuldugu alan
str1: .space 255	# parse isleminde '+' dan once parse edilen stringin tutuldugu alan
str2: .space 255	# parse isleminde '+' dan sonra parse edilen stringin tutuldugu alan
expression: .space 4  # '+' , '-' , '*' ifadelerinin tutuldugu alan
minusStr1: .space 4	  # str1 in onundeki '-' isareti varsa tutuldugu alan
minusStr2: .space 4	  # str2 in onundeki '-' isareti varsa tutuldugu alan
printString:  .asciiz "\nEntered : "
dot: .asciiz "."   
.text
.globl main

main:
        la $a0,printString  # Program calistiginda kullaniciya printString icinde bulunan ifadeyi consola aktarir
        li $v0,4
        syscall  

		## Kullanicidan string alinir ve $t0 in icine konur.
        li $v0,8 
        la $a0, stringBuf
        li $a1, 255
        move $t0,$a0 
        syscall

		la $s0, minusStr1  # str1 onunde "-" varsa $s0 da tutulur 
		la $s8, minusStr2  # str2 onunde "-" varsa $s0 da tutulur

		la $s1, str1    # load adress ile str1 in adresi $s1 ile gosterilir
		la $s2, str2    # load adress ile str2 in adresi $s2 ile gosterilir
		la $s3, expression   # load adress ile expression in adresi $s3 ile gosterilir
		
		## $s4 - $s7 arasýndaki regesterler sifirlanir
		add $s4, $zero, $zero
		add $s5, $zero, $zero
		add $s6, $zero, $zero
		add $s7, $zero, $zero
parser:

	loop1: 
		lb $t1, 0($t0)   # $t0 icinde bulunan stringBuf i load byte ile character olarak loop1 de dongu olarak dolanýr
		beq $t1, '-', minus1  # if ( $t1 == '-' ) goto minus1
		addi $s4, $s4, 1  # str1 in '.' ya kadar olan count degeri 
		beq $t1, '.', ignorePoint1  # if ( $t1 == '.' ) goto ignorePoint1
		sb $t1, 0($s1)   # store byte ile [s1] = [t1]
		addi $t0, $t0, 1  # $t0 pointer i 1 aratirlir 
		addi $s1, $s1, 1  # $s1 pointer i 1 aratirlir
		j loop1   # loop1 labeline atlar ve dongo gerceklesir

	minus1:
		sb $t1, 0($s0)	# store byte ile [s0] = [t1] '-'
		addi $s0, $s0, 1	# *s1 = *s1 + 1
		addi $t0, $t0, 1	# *t0= *t0 + 1
		j loop1		# loop1 labeline atlar ve dongo gerceklesir
	ignorePoint1:	# string icinde yer alan '.' lar ignore edilir.
		addi $t0, $t0, 1
		addi $s4, $s4, -1
		
	afterPoint1:  # string icinde '.' sonra expression dan oncesinin yapildigi dongu
		lb $t1, 0($t0)
		addi $s4, $s4, 1
		addi $s5, $s5, 1  # expression dan once yer alan '.' dan sonranin count degeri
		beq $t1, ' ', loop2		# if ( $t1 == ' ' ) goto loop2
		sb $t1, 0($s1)
		addi $t0, $t0, 1
		addi $s1, $s1, 1
		j afterPoint1

	## loop2 de expression dan once bulunan space ignore edilir 
	## dongu suresince expression denk gelir ise saveExpression labeline gidilir.
	loop2: 
		lb $t1, 0($t0)
		beq $t1, ' ', ignoreSpace1
		beq $t1, '+', saveExpression
		beq $t1, '-', saveExpression
		beq $t1, '*', saveExpression
		sb $t1, 0($s1)
		addi $t0, $t0, 1
		addi $s2, $s2, 1
		j loop2
	
	ignoreSpace1:
		addi $t0, $t0, 1
		addi $s4, $s4, -1
		addi $s5, $s5, -1
		j loop2
	saveExpression: 
		addi $t0, $t0, 1
		sb $t1, 0($s3)
		j loop3

	## stringBuf icinde loop 3 ile donerken expressiondan sonra 
	## if(*t1 == '-' ) goto minus2
	## if(*t1 == ' ' ) goto ignoreSpace2
	## if(*t1 == '.' ) goto ignorePoint2
	## str2 icin '.' ya kadar olan kisin load byte ile okunur ve str2 icine store byte ile atanir
	
	loop3: 
		lb $t1, 0($t0)
		beq $t1, '-', minus2
		addi $s6, $s6, 1
		beq $t1, ' ', ignoreSpace2
		beq $t1, '.', ignorePoint2
		sb $t1, 0($s2)
		addi $t0, $t0, 1
		addi $s2, $s2, 1
		j loop3
	ignoreSpace2:
		addi $t0, $t0, 1
		addi $s6, $s6, -1
		j loop3
	minus2:
		sb $t1, 0($s8)
		addi $s8, $s8, 1
		addi $t0, $t0, 1
		j loop3
	ignorePoint2:
		addi $t0, $t0, 1
		addi $s6, $s6, -1

	afterPoint2:
		lb $t1, 0($t0)
		beq $t1, 0, convertStrToInt
		addi $s6, $s6, 1
		addi $s7, $s7, 1
		sb $t1, 0($s2)
		addi $t0, $t0, 1
		addi $s2, $s2, 1
		j afterPoint2
	
	## Buraya kadar expressiondan onceki 1. sayinin string ifadesi
	## ve expressiondan sonraki 2. sayinin string ifadesi str1 ve str2 nin gosterdigi adresslere kaydedilmistir.
	## str1 i $s1 , str2 i $s2 regesteri gostermektedir.

	## convertStrToInt den itibaren checkExpression labeline kadar str1 ve str2 icinde bulunan ifadeler integer a basamak basamak donusturulur.
	convertStrToInt:
		addi $s6, $s6, -1
		addi $s7, $s7, -1
		##################
		res1:
			la $t3, str1
			add $s1, $zero, $zero
			add $t5, $zero, $zero
			j conLoop1

		conLoop1:
			li $v0, 11
			syscall
			lb $t2, 0($t3)
			addi $t3, $t3, 1
			addi $t5, $t5, 1
			bne $t2, 0, intl1
			beq $t2, 0, res2
			j conLoop1

		intl1:
			add $t6, $zero, $t5
			addi $t7, $zero, 1
			addi $t8, $zero, 10
			addi $t9, $t2, -48
			j calcDigit1
	
		calcDigit1:
			bne $t6, $s4, digits1
			mult $t7, $t9
			mflo $t7
			add $s1, $s1, $t7
			j conLoop1

		digits1:
			mult $t7, $t8
			mflo $t7
			addi $t6, $t6, 1
			j calcDigit1

		res2:
			la $t4, str2
			add $s2, $zero, $zero
			add $t5, $zero, $zero
			j conLoop2
		conLoop2:
			lb $t2, 0($t4)
			addi $t4, $t4, 1
			addi $t5, $t5, 1
			bne $t2, '\n', intl2
			beq $t2, '\n', checkExpression
			j conLoop2

		intl2:
			add $t6, $zero, $t5
			addi $t7, $zero, 1
			addi $t8, $zero, 10
			addi $t9, $t2, -48
			j calcDigit2
	
		calcDigit2:
			bne $t6, $s6, digits2
			mult $t7, $t9
			mflo $t7
			add $s2, $s2, $t7
			j conLoop2

		digits2:
			mult $t7, $t8
			mflo $t7
			addi $t6, $t6, 1
			j calcDigit2
#### Finish Parser ####

checkExpression:
	lb $t1, 0($s3)
	beq $t1,'+', equalOrNotEqual
	beq $t1,'-', equalOrNotEqual
	beq $t1,'*', equalOrNotEqual

## equalOrNotEqual str1 ve str2 inin '.' dan sonra length lerinin tutuldugu $s5 ve $s7 regesterlerindeki degerler 
## birbirine eþitmi diye kontrol edip compare ya da equal labellerine atlar
equalOrNotEqual:
	bne $s5, $s7, compare
	beq $s5, $s7, equal

## Matematiksel islemler:  $s1 ve $s2 de tutulan integerlar expressionlara gore matematiksel islemlerle $s4 registerine atilir
## ancak float degerlerin toplami oldugundan '.' dan sonrasi kisimlarin count degerlerine gore 10^digit-1 ile bolunerek float yapmak icin '.' nin nereye gelecegi hesaplanir
adder:
	add $s4, $s1, $s2
	div $s4, $t7
	mflo $s4
	mfhi $s6
	slt $t1, $s6, $zero
	beq $t1,1, changeMark
	j print
	
subtractor:
	sub $s4, $s1, $s2
	div $s4, $t7
	mflo $s4
	mfhi $s6
	slt $t1, $s6, $zero
	beq $t1,1, changeMark
	j print

changeMark:
	addi $t2, $zero, -1
	mult $s6, $t2
	mflo $s6
	j print


multiplier:
	mult $s1, $s2
	mflo $s4
	div $s4, $t7
	mflo $s4
	mfhi $s6
	slt $t1, $s6, $zero
	beq $t1,1, changeMark
	j print

equal:
	add $t6, $zero, $zero
	addi $t7, $zero, 1
	addi $t8, $zero, 10
	add $t9, $s5, $s7
	beq $t1,'*', loop11
	loop10:
		bne $t6, $s7, supplyZeros
		j minusCheck
	supplyZeros:
		mult $t7, $t8
		mflo $t7
		addi $t6, $t6, 1
		j loop10

	loop11:
		bne $t6, $t9, supplyZeros1
		j minusCheck
	supplyZeros1:
		mult $t7, $t8
		mflo $t7
		addi $t6, $t6, 1
		j loop11

compare:
	slt $t1, $s5, $s7
	beq $t1, 1, moreDigits
	beq $t1, 0, fewerDigits

fewerDigits:
	sub $t2, $s5, $s7
	add $t3, $zero, $zero
	addi $t4, $zero, 1
	addi $t5, $zero, 10
	
	add $t6, $zero, $zero
	addi $t7, $zero, 1
	addi $t8, $zero, 10
	lb $t1, 0($s3)
	beq $t1,'+', loop4
	beq $t1,'-', loop4
	beq $t1,'*', loop4

	loop4:
		bne $t3, $t2, supplyZero1
		mult $s2, $t4
		mflo $s2
		beq $t1,'*', X2i
		j loop6

	supplyZero1:
		mult $t4, $t5
		mflo $t4
		addi $t3, $t3, 1
		addi $s7, $s7, 1
		j loop4

	X2i:
		add $s7, $s5, $s7
		j loop6

	loop6:
		bne $t6, $s7, supplyZero5
		j minusCheck

	supplyZero5:
		mult $t7, $t8
		mflo $t7
		addi $t6, $t6, 1
		j loop6

moreDigits:
	sub $t2, $s7, $s5
	add $t3, $zero, $zero
	addi $t4, $zero, 1
	addi $t5, $zero, 10
	add $t6, $zero, $zero
	addi $t7, $zero, 1
	addi $t8, $zero, 10
	lb $t1, 0($s3)
	beq $t1,'+', loop7
	beq $t1,'-', loop7
	beq $t1,'*', loop7

	loop7:
		bne $t3, $t2, supplyZero2
		mult $s1, $t4
		mflo $s1
		beq $t1,'*', X2j
		j loop9

	supplyZero2:
		mult $t4, $t5
		mflo $t4
		addi $t3, $t3, 1
		addi $s5, $s5, 1
		j loop7
	X2j:
		add $s5, $s5, $s7
		j loop9

	loop9:
		bne $t6, $s5, supplyZero6
		j minusCheck
	supplyZero6:
		mult $t7, $t8
		mflo $t7
		addi $t6, $t6, 1
		j loop9

## str1 ve str2 integer a donusturulmeden once stringBuf icinde gezinirken onlarinde '-' varsa registerlerde tutulmustu.
## minusCheck: integer a donusturulen degerlerin onlerinde '-' varsa eger appendMinus1 ve appendMinus2 labellerine gondererek
## sayi * -1 yapýlarak negative integer a cevrilmistir
minusCheck:
	la $s0, minusStr1  ## value 1 "-" 
	la $s8, minusStr2  ## value 2 "-" 
	lb $t2, 0($s0)
	lb $t3, 0($s8)
	beq $t2, '-', appendMinus1
	beq $t3, '-', appendMinus2

	beq $t1,'+', adder
	beq $t1,'-', subtractor
	beq $t1,'*', multiplier

appendMinus1:
	addi $t0, $zero, -1
	mult $s1, $t0
	mflo $s1
	beq $t3, '-', appendMinus2
	beq $t1,'+', adder
	beq $t1,'-', subtractor
	beq $t1,'*', multiplier

appendMinus2:
	addi $t0, $zero, -1
	mult $s2, $t0
	mflo $s2
	beq $t1,'+', adder
	beq $t1,'-', subtractor
	beq $t1,'*', multiplier

## print degerleri float olarak ekrana cikti verir 
print:
	li $v0, 1
	move $a0, $s4
	syscall

	la $t1, dot
	move $a0, $t1
	li $v0, 4
	syscall

	li $v0, 1
	move $a0, $s6
	syscall

end:
    li $v0,10
    syscall


	