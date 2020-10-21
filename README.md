Hey there!

This year I studied computer's organisation II in College. I've been fascinated thus far with how computation is done on an assembler language and I want to share with you a little of my knowledge. 

Maybe this will become a series because I'm finding myself really captivated with this subject and I think a lot of people will understand better how programming works with this info.

But first things first

## :question: What is ASM?

![Alt Text](https://dev-to-uploads.s3.amazonaws.com/i/zckpommko2okfglnbo4y.png)

ASM, short for Assembler (or assembly), is not a unique language such as C, Java, Go or whatever, it is instead a program that converts code into machine language. This means there's assembler languages for the different types of machines. For example: There is assembler for the Intel and AMD processor' architectures (x86_64) and there's another for ARM architectures.

This tutorial is going to be oriented toward Intel's Architecture

## :wrench: What are we going to use?

![Alt Text](https://dev-to-uploads.s3.amazonaws.com/i/cz2fp3b87syicgzd2td5.png)

For this short program we are going to use NASM and whatever text editor you like. In my case, I'm going to use VS Code since it has some nice plugins.

To install NASM on Debian systems (Ubuntu, PopOs!, Linux Mint, etc..)

```bash
sudo apt-get update -y
sudo apt-get install -y nasm
```

#### I'm only going to show this example in a linux system since the sys calls are different for mac, hence the example won't work in that system (believe me, this post was intended for mac as well...)

## :building_construction: Structure of an ASM program

Ok, now we have our assembler and our Text Editor or IDE. What now?

Let's create a new file and name it helloWorld.asm

![Alt Text](https://dev-to-uploads.s3.amazonaws.com/i/xi78lnffa3dpbkctodim.png)

Now that we have our empty file. We need to determine how the file is going to be used. In ASM each file has 4 sections. This sections will always exist even if you don't define them. However, if you need one, you will have to do it.

The 4 sections are:

* **.data** : where we are going to declare our global initialised variables

* **.rodata** : where we are going to declare our global un-itialised constants

* **.bss** : where we are going to declare our global un-initialised variables

* **.text** : where we are going to define our code

## :clap: Hands On

Ok, so what we are trying to build here is a CLI program that prints Hello World!. Sounds fairly easy. But in order to do so, we need to inform the processor that this function that we are going to name 'start' is global to all the system. so we add our .text section with the 'start' function and the *global* statement outside the section. Like this:

![Alt Text](https://dev-to-uploads.s3.amazonaws.com/i/0yxzznxm22e8ctdd2yyj.png)

Since we don't want to use any fancy C functions, nor none of those other high level languages functions for the matter, we are going to rely on Syscalls.

Without digging that deep, Syscalls are just calls to the OS. We need to call the 0x80 interruption (on UNIX systems) and pass to that interruption the parameters we want it to handle.

For the function that we are going to use (sys_write) the interruption receives 4 parameters:

1. The function number (RAX)
2. Where do we want it to execute (RBX)
3. The direction of the memory we want to execute (RCX)
4. The size of the message in bytes (RDX)

RAX, RBX, RCX and RDX are just multi-purpose registers that we are going to use and that I'm going to explain in further chapters of this series. So bare with me for now.

So let's define the message first and let's call int 0x80 after that.

![Alt Text](https://dev-to-uploads.s3.amazonaws.com/i/mjlkmtep2m2ifkn7v59d.png)

A lot of new info here. Let's go line by line.

```x86asm
section .data
```

This is the section were we are going to define our 'Hello World!' string variable. Since it will be already initialised, we declare in .data

```x86asm
msg: DB 'Hello World!', 10
```

This is our new string. It's declared under the name *msg* and we initialise it with **DB** (define byte) the characters that will be displayed and a ', 10' which is going to be our *\n* character. What I want you to get out of this step is that Each char comprising 'Hello World!' takes one byte of memory. So by using DB we are asking the processor for a memory slot that will take 13 bytes (counting the space and \n char).

```x86asm
msgSize EQU $ - msg
```

This one is a little bit tougher. We are declaring a variable call msgSize that is going to step on the right end of Hello World! ($) and will subtract the address were your msg variable began. Thus leaving us with the bytes used for msg

We have our message, let's display it now!

![Alt Text](https://dev-to-uploads.s3.amazonaws.com/i/m981684zgahidn2yj46l.png)

Again, let's explain what is happening here

```x86asm
    mov rax, 4          ; function 4
    mov rbx, 1          ; stdout
    mov rcx, msg        ; msg
    mov rdx, msgSize    ; size
    int 0x80
```

Intel has a very weird way of doing things most of the time. So each line of text will be divided into 4 fragments again

```x86asm
   mov A, B   ; comments
```

1. Mov : an instruction which moves the elements from B to A
2. A   : the destiny Register/Memory
3. B   : the origin  Register/Memory
4. comments : where the comments are :p

So what we are doing in here is moving the number 4 to our RAX register (because sys_write is our function number 4 on UNIX). We move the number 1 to RBX (representing STDOUT). Then the memory in which *msg* is defined will be stored on RCX and finally the size on RCX. By calling *int 0x80* we are asking the interruption 0x80 to handle all the parameters we threw to it and do what it's supposed to do.

![Alt Text](https://dev-to-uploads.s3.amazonaws.com/i/hzj8buso23uoho8ferq9.png)

Our final step is to exit the program. And guess what? that requires another Syscall. In this case, our function will be number 1 (exit) and our parameter will be 0 (because that's the number we want to return. 0 usually means that the program was executed successfully while 1 means that it wasn't)

```x86asm
    mov rax, 1          ; function 1
    mov rbx, 0          ; code
    int 0x80
```

## :link: Assembling and Linking

Let's save our file as helloWorld.asm and head over to the terminal.

If you have already installed NASM, head to the folder where you saved your .asm file and assemble and link it.

Linux:

```bash
nasm -f elf64 -g -F DWARF helloWorld.asm
ld -e start -o helloWorld helloWorld.o
./helloWorld
```

And that's it for today. You should get a 'Hello World message on your terminal.

![Alt Text](https://dev-to-uploads.s3.amazonaws.com/i/vr0glcnzknvgu7eixs5o.jpeg)

If you want to see the full code, here is the Repository: [Hello World!](https://github.com/tomassirio/HelloWorldAsm)


