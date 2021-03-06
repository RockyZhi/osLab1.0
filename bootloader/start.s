# start.s

/* Start Protected Mode */
.code16

.global start
start:
	# 关闭中断
	cli 
	
	# 开启A20地址线
	pushw %ax
	movb $0x2,%al
	outb %al,$0x92
	popw %ax
	
	# 加载GDTR
	data32 addr32 lgdt gdtDesc 

	# TODO: 把cr0的最低位设置为1
	movl %cr0,%eax
	orb $1,%al
	movl %eax,%cr0

	# 长跳转切换到保护模式
	data32 ljmp $0x08, $start32 

.code32
start32:
	movw $0x10, %ax # setting data segment selector
	movw %ax, %ds
	movw %ax, %es
	movw %ax, %fs
	movw %ax, %ss
	movw $0x18, %ax # setting graphics data segment selector
	movw %ax, %gs
	movl $0x8000, %eax # setting esp
	movl %eax, %esp

	# TODO：编写输出函数，输出"Hello World" （Hint:参考app.s！！！）
	pushl $13
	pushl $message
	call displayStr
loop32:
	jmp loop32
message:
	.string "Hello,WOrld!\n\0"
displayStr:
	movl 4(%esp),%ebx
	movl 8(%esp),%ecx
	movl $((80*5+0)*2),%edi
	movb $0x0c,%ah
nextChar:
	movb (%ebx),%al
	movw %ax,%gs:(%edi)
	addl $2,%edi
	incl %ebx
	loopnz nextChar
	ret



.p2align 2
gdt: 
	# GDT 在这里定义 
	# .word limit[15:0],base[15:0]
	# .byte base[23:16],(0x90|(type)),(0xc0|(limit[19:16])),base[31:24]

	# 第一个描述符是NULL
	.word 0,0
	.byte 0,0,0,0

	# TODO：代码段描述符，对应cs
	.word 0xffff, 0 # LIMIT[15..0], BASE[15..0]
	.byte 0, 0x9a, 0xcf, 0 # BASE[23..16], P/DPL/S/TYPE/A, ..., BASE[31..24]

	# TODO：数据段描述符，对应ds
	.word 0xffff, 0
	.byte 0, 0x92, 0xcf, 0

	# TODO：图像段描述符，对应gs
	# Base address of this segment is 0xb8000.
	# But 1 word cannot express 0xb8000, so we move 0x0b into BASE[23..16].
	.word 0xffff, 0x8000
	.byte 0x0b, 0x92, 0xcf, 0


gdtDesc: 
	# gdtDesc definition here
	.word (gdtDesc - gdt -1)
	.long gdt


