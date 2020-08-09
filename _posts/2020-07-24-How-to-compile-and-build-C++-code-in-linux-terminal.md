---
layout: post
comments: true
title: How to compile and build C++ code in linux terminal
tags: [C++, g++, clang, compile, build, link, static library, shared library]
color: black
author: raha
feature-img: "assets/img/pexels/desk-messy.jpeg"
thumbnail: "assets/thumbnails/pexels/desk-messy.jpeg"
category: programming/CPP
excerpt_separator: <!--more-->
---

I'm sure there are plenty of good references out there for learning the C++ compilation and build process on Linux.
but i will say it again! and I hope it will be helpful.
<!--more-->

Table of Contents
* TOC
{:toc}

## Introduction

Understanding how programs are compiled and linked is a very basic knowledge that every C&C++ programmer should have.
Regardless of whether you are using an IDE or a build system, understanding the underlying mechanism is critical.

In this tutorial, I'll be using gnu g++ to compile C++ code, but the process is the same if you want to compile for C using gcc.
Even the Clang compiler is in a pretty similar format.


In this tutorial, I am assuming a complete C/C++ beginner. So stay with me when you know some parts. 
However, I am assuming that you have a very basic knowledge of Linux to be able to execute the commands.

In addition, I just want to convey the concepts, so sometimes I may use the informal terms.
I hope I can make it simple, clear and understandable.

* Note: The order of the parameters that you pass to the Gnu compiler is important!

## Most simple way using GNU C++ compiler
Suppose we have a single source file ```main.cpp``` like this

```cpp
#include <iostream>

int main(){
	std::cout << "Hello World" << std::endl;
	return 0;
}
	
```

Using the gnu C++ compiler on Linux is as simple as entering the following command on the terminal, where ```main.cpp``` is the name of the file that contains your C++ code.


```bash
$ g++ main.cpp
```

On Linux, your code will be compiled and linked to standard system libraries, and an executable file with the default name ```a.out``` will be created in the current working directory.
You can run it by typing the following command.

```bash
$ ./a.out
```

You can specify the output name you want by passing the ``` -o ``` switch to the compiler as follows.

```bash
$ g++ -o myapp main.cpp
```

You can also use the ```-std``` flag to explicitly specify the C++ standard.

```bash
$ g++ -std=c++11 -o myapp main.cpp
$ g++ -std=c++14 -o myapp main.cpp
```

I strongly recommend using this flag. over time you will learn what is available in each implementation of the standard.

You can also turn on many warnings while compiling your code.
You can consult the [```GCC Warning Option Page```](https://gcc.gnu.org/onlinedocs/gcc/Warning-Options.html) to check what's available and what's useful for specific needs.
but I usually use these three flags ``` -Wall -Wextra -Wpedantic ``` and recommend using them.

* -Wall: This enables all the warnings about constructions
* -Wextra: This enables some extra warning flags that are not enabled by -Wall
* -Wpedantic: Issue all the warnings demanded by strict ISO C and ISO C++

We can assume that this is the simplest form of compilation command for any serious C++ developer

```bash
$ g++ -std=c++11 -Wall -Wextra -Wpedantic -o myapp main.cpp
```


### Compiling multiple file project

Let's say we have two functions ```add``` and ```subt``` and each of them is in a separate file and we have the following file hierarchy.

```bash
.
├── add
│   ├── add.cpp
│   └── add.h
├── main.cpp
└── subt
    ├── subt.cpp
    └── subt.h
```
where the content of files are as follow:

```cpp
// this is content of add.h file
#ifndef _ADD_H_
#define _ADD_H_

int add(int,int);

#endif //_ADD_H_

```
```cpp
// this is content of add.cpp file
#include "add.h"

int add(int x,int y){
	return x+y;
}

```
```cpp
// this is content of subt.h file
#ifndef _SUBT_H_
#define _SUBT_H_

int subt(int,int);

#endif //_SUBT_H_

```
```cpp
// this is content of subt.cpp file
#include "subt.h"

int subt(int x,int y) {
	return x-y;
}

```

```cpp
// this is content of main.cpp file
#include "add.h"
#include "subt.h"

#include <iostreram>

int main(){
	std::cout << "Hello World" << std::endl;
	int sum = add(10,5);
	int sub = subt(10,5);
	std::cout << "sum: " << sum << std::endl;
	std::cout << "sub: " << sub << std::endl;
	return 0;
}
	
```
How do I compile this project?
The easiest thing to do is to compile and link them at once.

```bash
$ g++ -std=c++11 -Wall -Wextra -Wpedantic -Iadd -Isubt -o myapp main.cpp add/add.cpp subt/subt.cpp
```
That's it, you put the whole project together. You can notice a small change to our single file compilation above,
First we added two more filenames ```add/add.cpp``` and ```subt/subt.cpp``` with their relative path.
Second, we added the ```-I``` switch. The switch ```-I``` tells the compiler where to look for header files, so these paths ```add``` and ```subt``` will be searched after the path in your $PATH environment variable.

Another way to compile multiple file projects is to compile them one at a time and at the end ```link``` all together.
As you can see in the lines below, I am only compiling one source file in each of the first three commands.
The ```-c``` switch instructs the compiler to only compile the source file. 
The object file with the same name as the source file will be created in your working directory.
The fourth line is actually the link command. It calls the linker to link three object files ```main.o add.o subt.o``` and generate the executable output file.

Note: There is no need to pass the compiler swith like ```-std``` or ```-W``` or ```-I``` to the linker as it means nothing.


```bash
$ g++ -std=c++11 -Wall -Wextra -Wpedantic -Iadd -c add/add.cpp
$ g++ -std=c++11 -Wall -Wextra -Wpedantic -Isubt -c subt/subt.cpp
$ g++ -std=c++11 -Wall -Wextra -Wpedantic -Iadd -Isubt -c main.cpp

$ g++ -o myapp main.o add.o subt.o
```

Every build system out there automates these four command lines for you.
In a large project with many source files or include paths, It is cumbersome to manage them all by hand.
Even so, nothing prevents you from doing this for all or some of the files. Sometimes you may even find it helpful!
So keep it in mind. Build tools are there to automate this process, nothing else!

## How to generate a static library
Looking at the previous hierarchy of files, suppose we want to create two static libraries from each of the above folders and then link them to our project.

Note that libraries on Linux have a standard name conversion. For example, if you want to create a static library named ```X```, you should name it ```libX.a```. Also, you shouldn't have a ```main``` function in any of your libraries.

In our example we create two files named ```libadd.a``` and ```libsubt.a``` as follows:

```bash
$ g++ -std=c++11 -Wall -Wextra -Wpedantic -Iadd -c add/add.cpp
$ ar rcs libadd.a add.o

$ g++ -std=c++11 -Wall -Wextra -Wpedantic -Isubt -c subt/subt.cpp
$ ar rcs libsubt.a subt.o

```
I should mention one important thing here, static library on Linux is nothing more than an archive of some object files! You can move your object files around as they are (without creating archive), and later add them to your final project. We just put them in the standard archive to better organize them.

## How to build against static libraries
Now is the time for the final phase. We should compile the main file and then link it to our two libraries.
The fun starts with the link part. You can see the changes from the previous link command. 
Here we should add our two libraries with the ```-l``` switch. We also used ```-L``` (note the order of the parameters is important)

Usually you can use ```-lX``` to add library ```X``` (with the filename ```libX.a```) to the project.
But the linker should be able to find your library, we'll use the ```-L``` switch to tell the linker where to look for our library. we have specified ```.``` here, it means current directory.

```bash
$ g++ -std=c++11 -Wall -Wextra -Wpedantic -Iadd -Isub -c main.cpp
$ g++ -o myapp main.o -L. -ladd -lsub

```
Instead of calling linkers with the library name and path, we can use the full filename of the libraries with their relative or absolute path as follows:
This way, there is no need to provide a ```-L``` switch, but it usually results in a long and ugly format for large projects.

```bash
$ g++ -o myapp main.o ./libadd.a ./libsubt.a

```

Important note: when we use a static library, the object files in the library are added to your final executable, so you won't need that library later when you run your program, but the executable file is larger.

We will run the code like this:


```bash
$ ./myapp
```

Before moving on to the next part, delete any build artifacts from your working directory.

```bash
$ rm myapp
$ rm *.o
$ rm *.a
```

## How to generate a shared library
In the last part of the previous section, I mention that if we use a static library it will be added to our executable and the result will be bigger file.

Consider the case that many programs depend on the same library. If everyone adds this code to their excutable, it will be a huge waste of space. For this and other reasons, Linux offers a different type of library, which we call a shared library.

When you use a shared library, the linker does not add the library code to your executable, but rather finds the library at run time and executes the code in it.

This will keep the size of your excutable small. Duplication is not necessary if other programs need the same library.
However, we should provide some mechanic for the operating system to find the shared library at runtime if your programs need it.

Let's continue with our previous example. Suppose we decided to create a shared library from add and subt.
The compilation command should be changed as follows. With the option ```-fPIC``` the compiler can generate ```position-independent code```, the meaning is beyond the scope of this tutorial, but in short, it affects how the operating system will manage the memory address.

This time the library is not just an object file, you should create it using gcc with the ```-shared``` switch as follows. 
The shared object file on Linux has the same naming convention as static libraries, but with a ```.so``` extension. For example, library ```X``` has the file name ```libX.so```

```bash
$ g++ -std=c++11 -Wall -Wextra -Wpedantic -Iadd -fPIC -c add/add.cpp
$ g++ -shared -o libadd.so add.o

$ g++ -std=c++11 -Wall -Wextra -Wpedantic -Isubt -fPIC -c subt/subt.cpp
$ g++ -shared -o libsubt.so subt.o

```

## How to build against shared libraries
So far, so good. We created two shared libraries. Now we can go ahead and compile and build our project.
We first compile our program as before. Note that we didn't use -fPIC to compile the main program here.
and on the second line you will see the build command.
It seems just like the previous build command, when we were using a statically linked library, and this is another reason to use this format: consistency :)

```bash
$ g++ -std=c++11 -Wall -Wextra -Wpedantic -Iadd -Isub -c main.cpp
$ g++ -o myapp main.o -L. -ladd -lsub

```

Let's run the program now! Oops! Error!
The Linux OS linker gives you an error message, it cannot find the shared libraries it just created! 

Why?
because the ```-L``` switch that we provide during link time was provided to the linker. Now the dynamic loader is looking for these libraries and has no idea where to find them!

```bash
$ ./myapp
./myapp: error while loading shared libraries: libadd.so: cannot open shared object file: No such file or directory

```
I hope by this point you have a clear idea of how the shared library differs from the static library.
Let's solve the problem

### Add shared library path to environment variable
You can add the path of your shared library to the ```LD_LIBRARY_PATH``` environment variable. The dynamic loader finds the libraries in the path and runs your program without any problems.

```bash
$ export LD_LIBRARY_PATH=.
$ ./myapp

```
You can add this command to ```.profile``` for persistence.

### Add shared library to executable
Well, we don't like to update the environment variable every time we run a program.
We have other options: the Linux executable isn't just machine code, it has a lot of metadata, and we could add the shared library search path!
If you want to learn more about it, read about ```ELF - Executable and Linkable Format```, but that's not in the scope of this tutorial either.

We could modify our program's build command to embed the library path in the executable like this. 
Here ```-Wl``` is a switch that is passed directly to the linker and ```.``` This means the current directory in the ```rpath``` section of our executable file. 
When the Linux Runtime Loader executes the program, it will searches the path specified in rpath. You can pass any directory listing separated by colons to ```rapth```.

```bash
$ g++ -o myapp main.o -L. -ladd -lsub -Wl,-rpath,.

```

now we can run our program by simply typing it's name.

```bash
$ ./myapp

```


