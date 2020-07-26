---
layout: post
title: How to compile and build C++ code in linux terminal
tags: [g++, clang, compile, build, C++]
color: black
author: raha
feature-img: "assets/img/pexels/desk-messy.jpeg"
thumbnail: "assets/thumbnails/pexels/desk-messy.jpeg"
category: programming/CPP
excerpt_separator: <!--more-->
---

I am sure there are many good refrences for learning the C++ compilation and build process on Linux.
but i will say it again! and I hope it will be helpful.
<!--more-->

I hope I can put it in a simple, clear and understandable way.

* Note: The order of the parameters that you pass to the Gnu compiler is important!

# Most simple way using GNU C++ compiler

Using the gnu C++ compiler on Linux is as simple as typing the following command on the terminal, where ```main.cpp``` is the name of the file that contains your C++ code.

```bash
$ g++ main.cpp
```

Under Linux, your code is compiled and linked against standard system libraries and an executable file with the standard name ```a.out``` is created in the current working directory. 
You can run it by entering the following command.

```bash
$ ./a.out
```

You can specify the desired output name by passing the ```-o``` switch to the compiler as follows

```bash
$ g++ -o myapp main.cpp
```

You can also use the ```-std``` flag to explicitly specify the C ++ standard.

```bash
$ g++ -std=c++11 -o myapp main.cpp
$ g++ -std=c++14 -o myapp main.cpp
```

I strongly recommend using this flag as you will learn over time what is available in each implementation of the standard.

You can also activate many warnings while compiling your code. 
You can consult the [```GCC Warning Option Page```](https://gcc.gnu.org/onlinedocs/gcc/Warning-Options.html) to check what is available and what is useful for special requirements.
but usually I use these three flags ```-Wall -Wextra -Wpedantic``` and recommend using them.

* -Wall: This enables all the warnings about constructions
* -Wextra: This enables some extra warning flags that are not enabled by -Wall
* -Wpedantic: Issue all the warnings demanded by strict ISO C and ISO C++

So we can assume that this is the simplest form of the compile command for any serious C++ developer

```bash
$ g++ -std=c++11 -Wall -Wextra -Wpedantic -o myapp main.cpp
```
