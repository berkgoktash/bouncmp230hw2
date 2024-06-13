default:
	as -o postfix_translator.o src/postfix_translator.s
	ld -o postfix_translator postfix_translator.o
