---
layout: post
comments: true
title: How thread interface is implemented in c++11
tags: [union, variant, visitor, variadic, design pattern, C++]
color: black
author: raha
feature-img: "assets/img/pexels/pexels-skitterphoto-1920x1280.jpg"
thumbnail: "assets/thumbnails/pexels/pexels-skitterphoto-960x640.jpg"
category: programming/CPP
excerpt_separator: <!--more-->
---


<!--more-->
Table of Contents
* TOC
{:toc}

## Introduction

I am trying to implement a very simple header-only library that offers compilers with C++98 support a basic C++11 multithreading interface.

[ModernCPP](https://github.com/merajabi/ModernCPP), which is hosted on Github, is the result of this effort. It is a wrapper around the Linux implementation of POSIX threads.

In this post, I will go through the implementation of ```thread``` class similar to ```std::thread``` and try to reproduce examples from Herb Sutter's introduction to multithreading to demonstrate the compatibility of this interface with C++11.


## Implementation details

As you know, the term "move" was introduced in the standard in C++0x, but in C++98 we still have some types whose copying them has no meaning.
To emulate the "move" construct in C++98, I write something like boost, but very shallow as follows.


```cpp
template <typename T>
class right_reference {
	T* _ptr;
public:

	right_reference(T& u) : _ptr(addressof(u)) {};

	T* operator ->() const {
		return _ptr;
	}
};

template< typename U >
right_reference<U> refmove(U& u){
	return right_reference<U>(u);
}

template< typename U >
right_reference<U> refmove(right_reference<U> u){
	return u;
}

```
This provides basic functions for moving. For example, I can write Smart Guard for my raw pointer as follows:
In C++98, defining the constructor and the assignment operator privately is the option of making an object of calss not copyable.

```cpp
template<typename T>
class SmartGuard {
	mutable T *xPtr;

		SmartGuard(const SmartGuard &pg);
		SmartGuard& operator= (const SmartGuard &pg);

	public:
		SmartGuard(T* xp = nullptr){
			xPtr = xp;
		}
		SmartGuard& operator=(T* xp){
			assert(xPtr == nullptr);
			xPtr = xp;
			return *this;
		}

		SmartGuard(const right_reference<SmartGuard>& pg){ // its move constructor
			xPtr = pg->xPtr;
			pg->xPtr = nullptr;
		}
		SmartGuard& operator= (const right_reference<SmartGuard>& pg){ //  its move assignment operator
			assert(xPtr == nullptr);
			xPtr = pg->xPtr;
			pg->xPtr = nullptr;
			return *this;
		}

		~SmartGuard() {
			if(xPtr != nullptr){
				delete xPtr;
			}
		}
		T* release(){
			T* tmp=xPtr;
			xPtr=nullptr;
			return tmp;
		}
		T* get() const {return xPtr;}
		operator bool () const {
			return (xPtr != nullptr);
		}
		T* operator* () const {
			assert(xPtr != nullptr);
			return xPtr;
		}
		T* operator ->() const {
			assert(xPtr != nullptr);
			return xPtr;
		}
};
```
We can later use this class to protect our raw pointer as follows:

```cpp
struct Sample {
	int x;
	Sample():x(0){}
	Sample(int x):x(x){}
	void print() const {
		std::cout << x << std::endl;
	}
};

Sample* func(int x){
	SmartGuard<Sample> mv(new Sample(x));
	return mv.release();
}
int main(){
	{
		std::cout << "Test 1" << std::endl;
		SmartGuard<Sample> mv(new Sample(10));
		SmartGuard<Sample> mv2(refmove(mv));

		if(mv){
			mv->print();
		}
		mv2->print();
	}

	{
		std::cout << "Test 2" << std::endl;
		SmartGuard<Sample> mv(new Sample(15));
		SmartGuard<Sample> mv2;

		mv2 = refmove(mv);

		if(mv){
			mv->print();
		}
		mv2->print();
	}
	{
		std::cout << "Test 3" << std::endl;
		SmartGuard<Sample> mv( func(20) );
		mv->print();
	}
	{
		std::cout << "Test 4" << std::endl;
		SmartGuard<Sample> mv;
		mv = func(25);
		mv->print();
	}
	return 0;
}
```
Now that we have these tools under our belt, it is time to write the "thread" class.

In order for the thread class to work as expected, we need some simple data. The first is thread ID returned by "pthread_create".
second, the function that is executed in the thread. and third, the data that we could pass to this function.

The last could be a status of the thread. The thread class could look like this:

```cpp
class thread {
	pthread_t threadId;

	SomeType  data ;
	SomeFunc  func ;

	bool status;
};
```

SomeType and SomeFunc should clearly be user-defined types. To make this more general, I decided to implement the following structure.

Here I have a ThreadData template that inherits from ThreadDataBase. The function pointer is saved in "func". If data is available, it is saved in "param".

We will pass the static function "routine" to "pthread_create" as "start_routine" and the address of the object from this call as data.

In the main part of this static function we will cast the data to the class type and call the func passing data as input.

The specialization applies in the event that func does not receive any input parameters.

After ThreadData is inherited from ThreadDataBase, we can more easily store any dynamic instances in the Thread class.


```cpp
struct ThreadDataBase {
	virtual ~ThreadDataBase(){};
};

template<typename FuncType,typename ParamType=void>
struct ThreadData : public ThreadDataBase {
	FuncType func;
	ParamType param;

	ThreadData(FuncType func,ParamType param):func(func),param(param){};

	static void* routine(void *data){
		((ThreadData*)data)->func( ((ThreadData*)data)->param );
		return 0;
	}
};

template<typename FuncType>
struct ThreadData<FuncType,void> : public ThreadDataBase {
	FuncType func;

	ThreadData(FuncType func):func(func){};

	static void* routine(void *data){
		((ThreadData*)data)->func( );
		return 0;
	}
};

```

The definition of the thread class looks like this. Here we used our SmartGuard to keep our raw pointer safe.

We now have most thread handling features, except thread creation.

```cpp
	class thread {
		mutable pthread_t threadId;
		mutable SmartGuard<ThreadDataBase> data ;
		mutable bool status;

		thread(const thread& t);
		const thread& operator = (const thread& t) const;

	public:

		thread(const right_reference<thread>& t):threadId(t->threadId),data(refmove(t->data)),status(t->status) { // its move constructor
			t->threadId=-1;
			t->status=false;
		}

		const thread& operator = (const right_reference<thread>& t) const {  // its move assignment operator
			data=refmove(t->data);
			threadId=t->threadId;
			t->threadId=-1;
			status=t->status;
			t->status=false;
			return *this;
		}

		~thread(){
			if(status){
				pthread_cancel(threadId);
				status=false;
				std::terminate();
			}
		}

		void join() const {
			if(!status){
				throw system_error("joinable");
			}
			pthread_join( threadId, NULL);
			status=false;
		}

		void detach() const {
			if(!status){
				throw system_error("joinable");
			}
			pthread_detach(threadId);
			status=false;
		}

		bool joinable() const {
			return status;
		}					
	};
```

ok, let's go for thread creation, surely it should be a template function.
We receive two template parameters from the input, firstly a function and secondly some data, then we create an instance of ThreadData and save it in ``` data ```.

Finally, we create the thread by calling ```pthread_create```.
If thread creation was unsuccessful, we should throw an exception to matches the standard interface.
The second template is intended for the case that the function does not require any input.



That's it, we implemented the thread interface similar to ```std::thread```.

but be careful! We do not fully match with the ```std::thread```.
First, In order to be compatible with c++98, we did not use a Varidian template, so we only take one input parameter. But it is easy to extend this code.
Second, as I will explain in the example section, this implementation does not support all kind of ```std::thread``` constructor.
Third, our move construct is somewhat limited in its functions, and you shouldn't threaten it as you use it in C ++ 11.

```cpp
		template<typename FuncType,typename ParamType>
		thread(FuncType functor,ParamType param):threadId(0),data( new ThreadData<FuncType,ParamType>(functor,param) ),status(false){
			int error = pthread_create( &threadId, NULL, &ThreadData<FuncType,ParamType>::routine, *data);

			if(error!=0){
				throw system_error("thread");
			}
			status=true;
		}

		template<typename FuncType>
		thread(FuncType functor):threadId(0),data( new ThreadData<FuncType>(functor)),status(false){
			int error = pthread_create( &threadId, NULL, &ThreadData<FuncType>::routine, *data);

			if(error!=0){
				throw system_error("thread");
			}
			status=true;
		}

```
## Some sample usage of thread interface

In this section, I will give step-by-step examples to show the functionality of our thread interface.

Let's first assume a simple function that prints "Hello World" in the output. Our code looks something like this.

simple yes :) and you can compile it with the ```-std=c++98``` compiler flag !


```cpp
#include "ModernCPP.h"
#include <iostream>

void hello(){
    std::cout<< "Hello World" <<std::endl;
}

int main() {
	thread t1(hello);
	t1.join();
	return 0;
}
```

Let's test two threads in parallel,
Each function takes an integer and increments an atomic counter. 

Atomic is not too difficult to implement for trivial types in c++98. Take a look at the ModernCPP project "include/atomic.h".

```cpp
#include "ModernCPP.h"
#include <iostream>

atomic<unsigned long> counter(0);

void inc(long x){
	for(long i=0;i<x;i++){
		counter++;
	}
}

int main() {
	counter=0;
	thread t1(inc,10);

	int x=10;
	thread t2(inc,x);

	void (*fp)(long) = inc;
	thread t3(fp,10);

	t3.join();
	t2.join();
	t1.join();

	assert(counter.load()==30);
    std::cout<<counter<<std::endl;
	return 0;
}
```
What about referencing a function?

Simply, we have implemented the ```ref``` function similar to ```std::ref``` and you can use it like this:

```cpp
#include "ModernCPP.h"
#include <iostream>

void non_safe_incref(long& x){
	for(long i=0;i<10;i++){
		x++;
	}
}
int main() {
	int x=10;
	thread t1(non_safe_incref,ref(x));
	t1.join();
	assert(x==20);
    std::cout<< x <<std::endl;
	return 0;
}

```

But be careful! the function is not thread safe. It is open to the race if it runs in parallel.

I also implemented ```std::mutex``` -like interface as long as ```lock_guard``` 

The thread-safe version would be as follows. compile it with the ```-std=c++98``` compiler flag !

```cpp
#include "ModernCPP.h"
#include <iostream>

mutex m;

void safe_incref(long& x){
	lock_guard<mutex> lk(m);
	for(long i=0;i<10;i++){
		x++;
	}
}

int main() {
	int x=10;
	thread t1(safe_incref,ref(x));
	thread t2(safe_incref,ref(x));
	t2.join();
	t1.join();
	assert(x==30);
    std::cout<< x <<std::endl;
	return 0;
}

```

In the next listing, we pass an object of a user defined type to the thread function.

```cpp
#include "ModernCPP.h"
#include <iostream>

atomic<unsigned long> counter(0);

class Sample {
	long x;
	public:
	Sample(long x=10):x(x){}
	long Get() const {return x;}
};

void inc_sample(const Sample& x){
	for(long i=0;i<x.Get();i++){
		counter++;
	}
}
int main() {
	counter=0;
	Sample obj(10);
	thread t1(inc_sample,obj);
	thread t2(inc_sample,Sample(10));
	t2.join();
	t1.join();
	assert(counter.load()==20);
    std::cout<<counter<<std::endl;
	return 0;
}

```

Passing a reference to an object is the same as before.


```cpp
#include "ModernCPP.h"
#include <iostream>

class Sample {
	long x;
	public:
	Sample(long x=10):x(x){}
	long Get() const {return x;}
	void Run (){
		lock_guard<mutex> lk(m);
		for(long i=0;i<10;i++){
			x++;
		}
	}

};

void inc_sample(Sample& obj){
	obj.Run();
}
int main() {
	Sample obj(0);
	thread t1(inc_sample,ref(obj));
	thread t2(inc_sample,ref(obj));
	t2.join();
	t1.join();
	assert(obj.Get()==20);
    std::cout<<obj.Get()<<std::endl;
	return 0;
}

```

Passing function objects is also easy. Look at the following code:
Only the third case is not possible in our implementation.

```cpp
#include "ModernCPP.h"
#include <iostream>

atomic<unsigned long> counter(0);

class Sample {
	long x;
	public:
	Sample(long x=10):x(x){}
	long Get() const {return x;}
	void operator () (){
		for(long i=0;i<x;i++){
			counter++;
		}
	}
};
int main() {
	counter=0;
	Sample obj;

	thread t1(obj);

	thread t2((Sample())); //this is to avoid what's known as C++'s most vexing parse: 
							// without the parentheses, the declaration is taken to be a declaration of a function called t4 

	// thread t3 = thread(Sample()); // can not copy construct a thread

	thread t4(Sample(10));

	t4.join();
	t2.join();
	t1.join();

	assert(counter.load()==30);
	std::cout<<counter<<std::endl;
	return 0;
}
```

## Passing thread objects to standard containers

So far, so good, We have basic thread functions, but we usually have a pool of thread. How to manage that?

Well, thread objects are move-only, and in C++98 there is little support for that, also we have no ```emplace``` method for standard containers.

but here's a trick !
If we change the SmartGuard class so that the copy constructor and copy assignment operator behave like their move counterparts, we are there !! Do not forget to make them public.

```cpp
	SmartGuard(const SmartGuard &pg) { // its move constructor
		xPtr = pg.xPtr;
		pg.xPtr = nullptr;
	}

	SmartGuard& operator= (const SmartGuard &pg) { //  its move assignment operator
		assert(xPtr == nullptr);
		xPtr = pg.xPtr;
		pg.xPtr = nullptr;
		return *this;
	}

```
Check out the code below. Do you like that? and it's all in C++98 !!


```cpp
#include "ModernCPP.h"
#include <iostream>

atomic<unsigned long> counter(0);

class Sample {
	long x;
	public:
	Sample(long x=10):x(x){}
	long Get() const {return x;}
	void operator () (){
		for(long i=0;i<x;i++){
			counter++;
		}
	}
};

int main() {
	counter=0;
	std::vector<SmartGuard<thread> > tvec;
	for(int i=0; i<3; i++){
		Sample obj(10);
		SmartGuard<thread> tg ( new thread(obj) );
		tvec.push_back(refmove(tg));
	}
	for(int i=0; i<3; i++){
		tvec[i]->join();
	}
	std::cout<<counter<<std::endl;
}
```

We can also implement the main function as follows:

```cpp
int main() {
	counter=0;
	std::vector<SmartGuard<thread> > tvec;
	for(int i=0; i<3; i++){
		tvec.push_back(new thread(Sample(10)));	
	}
	for(int i=0; i<3; i++){
		tvec[i]->join();
	}
    std::cout<<counter<<std::endl;
	return 0;
}
```
Could we pass this vector on? why not!
Check out the code below.

However, you should remember that returning a large vector from a function in C++98 can be costly.

Nevertheless, everything works as you would expect.

```cpp
#include "ModernCPP.h"
#include <iostream>

atomic<unsigned long> counter(0);

class Sample {
	long x;
	public:
	Sample(long x=10):x(x){}
	long Get() const {return x;}
	void operator () (){
		for(long i=0;i<x;i++){
			counter++;
		}
	}
};

std::vector<SmartGuard<thread> > createList(){
	std::vector<SmartGuard<thread> > tvec;
	for(int i=0; i<3; i++){
		Sample obj(10);
		SmartGuard<thread> tg ( new thread(obj) );
		tvec.push_back(refmove(tg));
	}
	return tvec;
}
void createList(std::vector<SmartGuard<thread> >& tvec){
	for(int i=0; i<3; i++){
		Sample obj(10);
		tvec.push_back(new thread(obj));
	}
}
void waitList(const std::vector<SmartGuard<thread> >& tvec){
	for(int i=0; i<3; i++){
		tvec[i]->join();
	}
}

int main() {
	counter=0;
	std::vector<SmartGuard<thread> > tvec1;
	createList(tvec1);
	std::vector<SmartGuard<thread> > tvec2 = createList();

	waitList(tvec2);
	waitList(tvec1);
	std::cout<<counter<<std::endl;
	return 0;
}

```

## Running method functions in parallel, bind implementation

In C++11 you can execute a method function of a class in thread, by passing the address of this function and the address of the object as a second parameter.
So this is a valid C ++ 11 code

```cpp
class Sample {
	long x;
	public:
	Sample(long x=10):x(x){}
	long Get() const {return x;}
	void Run (){
		lock_guard<mutex> lk(m);
		for(long i=0;i<10;i++){
			x++;
		}
	}
};
int main(){
	Sample obj;
	std::thread t(&Sample::Run, &obj);
	t.join()
	return 0;
}
```
Our thread implementation does not offer this interface yet. but I have a workaround for that! via bind !!

Yes, "std::bind" is a c++0x implementation, but I've implemented it for simple cases.

Check out this listing for the result.

Now this is a valid c++98 code. Details of bind implementation can be found in "include/typetraits.h" on github

```cpp
#include "ModernCPP.h"
#include <iostream>

class Sample {
	long x;
	public:
	Sample(long x=10):x(x){}
	long Get() const {return x;}
	void Run (){
		lock_guard<mutex> lk(m);
		for(long i=0;i<10;i++){
			x++;
		}
	}
};
int main(){
	Sample obj;
    thread t(bind(&Sample::Run, &obj));
	t.join()
	return 0;
}
```

More details about this project can be found in the Github repository.
The source code of all examples presented here can be found in the project under "test / basic.cpp".


## References
* [ModernCPP](https://github.com/merajabi/ModernCPP)

