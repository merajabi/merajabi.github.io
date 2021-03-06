---
layout: post
comments: true
title: What is variant? A perfect application of visitor pattern
tags: [union, variant, visitor, variadic, design pattern, C++]
color: black
author: raha
feature-img: "assets/img/pexels/pexels-pixabay-1920x1280.jpg"
thumbnail: "assets/thumbnails/pexels/pexels-pixabay-960x640.jpg"
category: programming/CPP
excerpt_separator: <!--more-->
---

Do you remember the union construct in C language? As of C++11, you can use any object as part of the Union construct, but it's not type-safe. In c++17 ```std::variant``` is added as a type-safe implementation of a union-like construct.

<!--more-->
Table of Contents
* TOC
{:toc}

## Introduction

In this tutorial, I will explain why implementing "variant" is difficult and how we can solve it using the visitor design pattern.
I have often seen many sample applications of visitor patterns that are easier to solve directly, but this time I couldn't think of an easier solution, so you will see the true power of the visitor pattern.

Before we proceed, however, you should review these references to sharpen your mind.

Read Stroustrup's page on C++11FAQ about union to remember about union.
* [Bjarne Stroustrup's C++11FAQ](https://www.stroustrup.com/C++11FAQ.html#unions)

Read about bit fields and the fun you may experience
* [cppreference on bit field](https://en.cppreference.com/w/c/language/bit_field)
* [union that can access bits nibbles & bytes](https://stackoverflow.com/questions/20005349/define-union-that-can-access-bits-nibbles-bytes)

Read about type punning and ```reinterpret_cast``` in modern C++ 

* [wikipedia on type punning](https://en.wikipedia.org/wiki/Type_punning)
* [stackoverflow type punning in C & C++](https://stackoverflow.com/questions/25664848/unions-and-type-punning)
* [GCC support for type punning](https://gcc.gnu.org/onlinedocs/gcc/Optimize-Options.html#Type%2Dpunning)

Read about ```std::variant``` and ```std::visit```. Read Bartek's blog about ```std::variant```. In the first part you will find an example of a union in C++11 and you will see why it is not type safe.

Also at the end of the same page you can find some application of ```std::variant```.
* [Bartek's coding blog: about std::variant](https://www.bfilipek.com/2018/06/variant.html)

You should also read about visitor patterns which is a central part of this blog post, Read it from the original Gang of Four book.
* [Design Patterns: Elements of Reusable Object-Oriented Software](https://www.amazon.com/Design-Patterns-Elements-Reusable-Object-Oriented/dp/0201633612)

If you are new to design patterns watch these two on youtube.
* [Derek Banas video on visitor pattern](https://www.youtube.com/watch?v=pL4mOUDi54o)
* [video on visitor pattern](https://www.youtube.com/watch?v=TeZqKnC2gvA)


## Why variant is hard?!

Note: For the sake of simplicity, In this post I assume that we will compile with C++14 . Changing this code to C++11 is straightforward.

ok, Suppose we want to implement a variant class of some types, so we should have the following structure.

```cpp
template <typename ... Types>
struct MyVariant {
	char data[ std::max({1ul, sizeof(Types)...}) ];
};
```

We created the array of characters with a length equal to the maximum of all sizes. ```std::max``` is defined ```constexpr``` in c++14 so there is no problem.

Of course, each of our types will fit in this array, but we've overlooked two things. 

First, char is aligned to one byte. What if our type has a bigger alignment requirement? Well, we should consider the maximum of our types.

Second, what is our current active type? You know that only one of the type is active in the "variant" class at any point in its life.

So we may need an index to track which one is active. Therefore, we can change the definition of our class as follows

```cpp
template <typename ... Types>
struct MyVariant {
	alignas( std::max({alignof(Types)...}) ) char data [ std::max({1ul, sizeof(Types)...}) ];
	int index;
};
```

ok, now the important observation:

The fact that we are responsible for calling the constructor and destructor of different types in this block of memory is our problem.

But this problem is not difficult, because we should know which type is currently active! It's difficult, because we don't have an easy way to create any objects of an arbitrary at runtime in C++!

Consider the following code: We called a constructor on a block of memory, then saved and retrieved some data, and finally called the destructor. everything seems fine.

For basic types like int, you don't even have to call the constructor and destructor, a simple conversion is fine.

```cpp
#include <iostream>
#include <algorithm>
#include <type_traits>

template <typename ... Types>
struct MyVariant {
	alignas( std::max({alignof(Types)...}) ) char data [ std::max({1ul, sizeof(Types)...}) ];
	int index;
};

int main () {
	using T1 = int;
	using T2 = std::string;

	MyVariant<T1,T2> obj;

	{
		obj.index = 0;
		::new(obj.data) T1();		
		*reinterpret_cast<T1*>(obj.data) = 10;
		std::cout << *reinterpret_cast<T1*>(obj.data) << std::endl;
		reinterpret_cast<T1*>(obj.data)->~T1();
	}
	{
		obj.index = 1;
		::new(obj.data) T2();
		*reinterpret_cast<T2*>(obj.data) = "Hi";
		std::cout << *reinterpret_cast<T2*>(obj.data) << std::endl;
		reinterpret_cast<T2*>(obj.data)->~T2();
	}
	return 0;
}
```

So what's the problem? The problem is that T1 and T2 are compile-time definitions. You cannot save them anywhere and use them at runtime!

We need something like that, but we don't have it! We cannot store a name of a type in a variable and later create an object from this type in c++.

For this to work, you need reflection!


```cpp
	using T1 = int;
	using T2 = std::string;

	// this code is not correct and will not compile !!!
	imaginary_c++_type mytypes[2] = {T1, T2};

	MyVariant<T1,T2> obj;
	obj.index = 0;

	....
	{
		*reinterpret_cast<mytypes[obj.index]*>(obj.data) = 10;
	}

```

## The solution

Ok, I hope the problem is clear now, so what's the solution?

The solution might look like this: We create a function that does something with any type we need and store a pointer to each function in an array of function pointers. Later at runtime we can call these functions based on their index.

```cpp
using T1 = int;
using T2 = std::string;

using CallerType = void(*)(void*);

template<typename T>
void caller(void *data){
	std::cout << *reinterpret_cast<T*>(data) << std::endl;
}

const CallerType funcArray[2]={caller<T1>,caller<T2>};
```

It seems like a cool idea, and we could go a little further, instead of doing something directly in this function, we can pass a type-casted object to another function that we got from the input!

Woow, doesn't seem interesting? As you can see in the list below, it is obvious that I am using visitors. What I do by definition is the visitor pattern and you will soon see how powerful it is.

```cpp
using T1 = int;
using T2 = std::string;

struct IVisitor{
	virtual void operator()(T1 &data) const = 0;
	virtual void operator()(T2 &data) const = 0;
};

using CallerType = void(*)(const IVisitor&, void*);

template<typename T>
void caller(const IVisitor& functor, void *data){
	functor(*reinterpret_cast<T*>(data));
}

const CallerType funcArray[2]={caller<T1>,caller<T2>};
```

lets go on an implement a printer visitor, it will look like this:

```cpp
struct Printer : public IVisitor{
	void operator()(T1 &data) const {
		std::cout << data << std::endl;
	}
	void operator()(T2 &data) const {
		std::cout << data << std::endl;
	}
};
```

ok, following the same analogy, we can write constructor, destructor, and assignment visitor, and the full listing for our simple example is as follows:

```cpp
#include <iostream>
#include <algorithm>
#include <type_traits>

template <typename ... Types>
struct MyVariant {
	alignas( std::max({alignof(Types)...}) ) char data [ std::max({1ul, sizeof(Types)...}) ];
	int index;
};

using T1 = int;
using T2 = std::string;

struct IVisitor{
	virtual void operator()(T1 &data) const = 0;
	virtual void operator()(T2 &data) const = 0;
};

using CallerType = void(*)(const IVisitor&, void*);

template<typename T>
void caller(const IVisitor& functor, void *data){
	functor(*reinterpret_cast<T*>(data));
}

const CallerType funcArray[2]={caller<T1>,caller<T2>};

struct Ctor : public IVisitor{
	void operator()(T1 &data) const {
		::new(&data) T1();		
	}
	void operator()(T2 &data) const {
		::new(&data) T2();		
	}
};

struct Dtor : public IVisitor{
	void operator()(T1 &data) const {
		data.~T1();
	}
	void operator()(T2 &data) const {
		data.~T2();
	}
};

struct Printer : public IVisitor{
	void operator()(T1 &data) const {
		std::cout << data << std::endl;
	}
	void operator()(T2 &data) const {
		std::cout << data << std::endl;
	}
};

struct Assigner : public IVisitor{
	T1 x1;
	T2 x2;
	Assigner(T1 x1,T2 x2):IVisitor(),x1(x1),x2(x2){}
	void operator()(T1 &data) const {
		data = x1;
	}
	void operator()(T2 &data) const {
		data = x2;
	}
};

int main () {

	MyVariant<T1,T2> obj;
	{
		obj.index = 0;
		funcArray[obj.index](Ctor{},obj.data);
		funcArray[obj.index](Assigner{10,"Hi"},obj.data);
		funcArray[obj.index](Printer{},obj.data);
		funcArray[obj.index](Dtor{},obj.data);
	}
	{
		obj.index = 1;
		funcArray[obj.index](Ctor{},obj.data);
		funcArray[obj.index](Assigner{10,"Hi"},obj.data);
		funcArray[obj.index](Printer{},obj.data);
		funcArray[obj.index](Dtor{},obj.data);
	}
	return 0;
}
```

Now we can dynamically choose which operation to use at runtime.
We could further simplify the main function if we write a visit function like this.

```cpp
template <typename ... Types>
void visit(const IVisitor& functor,MyVariant<Types...> &obj){
	funcArray[obj.index](functor,obj.data);
}

int main () {
	{
		obj.index = 0;
		visit(Ctor{},obj);
		visit(Assigner{10,"Hi"},obj);
		visit(Printer{},obj);
		visit(Dtor{},obj);
	}
	{
		obj.index = 1;
		visit(Ctor{},obj);
		visit(Assigner{10,"Hi"},obj);
		visit(Printer{},obj);
		visit(Dtor{},obj);
	}
	return 0;
}

```

## How to implement a really variadic variant

Ok, so far we have seen what a variant is, why it is difficult and how to implement it using the visitor pattern.
However, you noticed that our implementation is not really variable so far, we only looked at two types.
In this section I'm going to generalize a little so we can have a variadic.

As you can see in the list below, the variant class is the same as before, but the visitor part has changed significantly.
I renamed the funcArray to actionArray and it is now a static array in the visitor structure. In addition, the caller is renamed to visit and is now a member function of the visitor structure.

This form opens my hand to define a signature of a function, which is saved in actionArray as a template.
If you look up, the CallerType was defined as follows:

```cpp
using CallerType = void(*)(const IVisitor&, void*);
```

In addition, the function was template. There was no sign of a template parameter in the signature.
However, I cannot pass Lambda to this function because the Lambda type is only known to the compiler. So I changed this signature as follows:

```cpp
template <typename Functor> 
using VisitorSignature = void(Functor, void*);
```

Now "Functor" can be any type, to properly express it: any functor!
Here we have another change too. Visit Do not call the visitor directly on the object.

First, the "TypeCastVisitor" object is called, which, as the name suggests, type-cast the data and then calls the specified visitor on it. This will open our hands very much when implementing visitors. 

If you look at the end of following listing, just above the main function, you will see how differently the visitors are implemented.

In the main function I also showed how to use Lambda as a visitor.

So far I have implemented the building blocks for creating a Variant class. But as you can see, we still do the bookkeeping by hand. As you may suspect, the rest is straightforward. We will call these visitors in the variant member function to automate the process.

In the next section I will present a more complete implementation of the variant class.

```cpp
#include <iostream>
#include <algorithm>
#include <type_traits>
#include <functional>
#include <string>
#include <cassert>

template <typename ... Types>
struct Variant;

///////////////////////////////////////////////
//				***	Visitor Caller ***

template <typename Functor>
using VisitorSignature = void(Functor, void*);

template <template <typename> class RV,typename Functor, typename ... Types>
struct Visitor {
	static const std::function<VisitorSignature<Functor>> actionArray[sizeof...(Types)];

	void visit(Functor functor, Variant<Types...>& obj) const {
		actionArray[obj.index](functor,obj.data);
	}
};

template <template <typename> class RV,typename Functor, typename ... Types>
const std::function<VisitorSignature<Functor>> Visitor<RV,Functor,Types...>::actionArray[sizeof...(Types)] = {RV<Types>()...};

template <typename T>
struct TypeCastVisitor {
	template <typename Functor>
	void operator () (Functor functor, void* data) const {
		functor(*reinterpret_cast<T*>(data));
	}
};

template <typename ... Types, typename Functor>
void Visit(Functor functor, Variant<Types...>& obj){
	Visitor<TypeCastVisitor,Functor,Types...> visitor;
	visitor.visit(functor,obj);
}

///////////////////////////////////////////////
//				***	Variant Class ***

template <typename ... Types>
struct Variant {
	alignas( std::max({alignof(Types)...}) ) char data [ std::max({1ul, sizeof(Types)...}) ];
	int index;
};

///////////////////////////////////////////////
//				***	Visitors ***

struct default_construct_visitor {
	template <typename T>
	void operator()(T& data) const {
		::new(&data) T();
	}
};

struct destroy_visitor {
	template <typename T>
	void operator()(T& data) const {
		data.~T();
	}
};

struct print_visitor {
	template <typename T>
	void operator () (T& data) const {
		std::cout << data << std::endl; 
	}
};

template <typename T>
struct set_visitor {
	T temp;
	set_visitor(const T& temp):temp(temp){}
	void set(const T& t){ temp = t; }

	void operator()(T& data) const {
		data =  temp;
	}

	template <typename U>
	void operator () (U&) const {}
};

template <typename T>
struct get_visitor {
	T temp;
	T get() const {return temp;};

	void operator()(T& data) {
		temp = data;
	}

	template <typename U>
	void operator () (U&) const {}
};

int main(){
	{
		Variant<int,std::string> obj;
		{
			obj.index = 1;

			Visit(default_construct_visitor{},obj);
			Visit(set_visitor<std::string>{"Hi"},obj);
			Visit(print_visitor{},obj);
			Visit(destroy_visitor{},obj);
		}
		{
			obj.index = 0;

			Visit(default_construct_visitor{},obj);
			Visit(set_visitor<int>{10},obj);
			Visit(print_visitor{},obj);
			Visit(destroy_visitor{},obj);
		}
		{
			obj.index = 1;

			Visit(default_construct_visitor{},obj);
			Visit(set_visitor<std::string>{"Hello"},obj);
			Visit(print_visitor{},obj);
			Visit(destroy_visitor{},obj);
		}

	}
	{
		Variant<int,std::string,double> obj;
		{
			obj.index = 1;

			Visit(default_construct_visitor{},obj);

			set_visitor<std::string> setvisitor{"Hi"};
			Visit(setvisitor,obj);

			Visit([](auto& data){std::cout << data << std::endl;}
				,obj);
			Visit(destroy_visitor{},obj);
		}
		{
			obj.index = 2;

			Visit(default_construct_visitor{},obj);

			set_visitor<double> setvisitor{1.2};
			Visit(setvisitor,obj);

			Visit([](auto& data){std::cout << data << std::endl;}
				,obj);
			Visit(destroy_visitor{},obj);
		}
	}

}

```
## Details of complete variant implementation

We have seen some basic building blocks so far, now is the time to complete our variant class. We'll add a few more tools first and will be there soon.

First of all, we need a tool for copying and moving objects of the variant class. Therefore we will expand our visitor as follows:

```cpp
template <typename Functor>
using VisitorSignature = void(Functor, void*);

template <typename Functor>
using VisitorSignatureCopy = void(Functor, void*,const void*);

template <typename Functor>
using VisitorSignatureMove = void(Functor, void*, void*);

template <template <typename> class RV,typename Functor, typename ... Types>
struct Visitor {
	static const std::function<VisitorSignature<Functor>> actionArray[sizeof...(Types)];
	static const std::function<VisitorSignatureCopy<Functor>> actionArrayCopy[sizeof...(Types)];
	static const std::function<VisitorSignatureMove<Functor>> actionArrayMove[sizeof...(Types)];

	void visit(Functor functor, Variant<Types...>& obj) const {
		actionArray[obj.index](functor,obj.data);
	}
	void visit(Functor functor, Variant<Types...>& obj1,const Variant<Types...>& obj2) const {
		actionArrayCopy[obj1.index](functor,obj1.data,obj2.data);
	}
	void visit(Functor functor, Variant<Types...>& obj1,Variant<Types...>&& obj2) const {
		actionArrayMove[obj1.index](functor,obj1.data,obj2.data);
	}
};

template <template <typename> class RV,typename Functor, typename ... Types>
const std::function<VisitorSignature<Functor>> Visitor<RV,Functor,Types...>::actionArray[sizeof...(Types)] = {RV<Types>()...};

template <template <typename> class RV,typename Functor, typename ... Types>
const std::function<VisitorSignatureCopy<Functor>> Visitor<RV,Functor,Types...>::actionArrayCopy[sizeof...(Types)] = {RV<Types>()...};

template <template <typename> class RV,typename Functor, typename ... Types>
const std::function<VisitorSignatureMove<Functor>> Visitor<RV,Functor,Types...>::actionArrayMove[sizeof...(Types)] = {RV<Types>()...};

template <typename T>
struct TypeCastVisitor {

	template <typename Functor>
	void operator () (Functor functor, void* data) const {
		functor(*reinterpret_cast<T*>(data));
	}

	template <typename Functor>
	void operator () (Functor functor, void* data1, const void* data2) const {
		functor(*reinterpret_cast<T*>(data1),*reinterpret_cast<const T*>(data2));
	}

	template <typename Functor>
	void operator () (Functor functor, void* data1, void* data2) const {
		functor(*reinterpret_cast<T*>(data1),static_cast<T&&>(*reinterpret_cast<T*>(data2)));
	}
};

template <typename ... Types, typename Functor>
void Visit(Functor functor, Variant<Types...>& obj){
	Visitor<TypeCastVisitor,Functor,Types...> visitor;
	visitor.visit(functor,obj);
}
template <typename ... Types, typename Functor>
void Visit(Functor functor, Variant<Types...>& obj1,const Variant<Types...>& obj2){
	Visitor<TypeCastVisitor,Functor,Types...> visitor;
	visitor.visit(functor,obj1,obj2);
}
template <typename ... Types, typename Functor>
void Visit(Functor functor, Variant<Types...>& obj1,Variant<Types...>&& obj2){
	Visitor<TypeCastVisitor,Functor,Types...> visitor;
	visitor.visit(functor,obj1,std::move(obj2));
}

```

As you can see, I've added more functions, one that accepts an l-value variant for copying and another that accepts an r-value variant for moving.
Now I can implement the copy and move as follows:


```cpp
struct copy_visitor {
	template <typename T>
	void operator()(T& data1,const T& data2) const {
		data1 =  data2;
	}
};

struct move_visitor {
	template <typename T>
	void operator()(T& data1,T&& data2) const {
		data1 =  std::move(data2);
	}
};

```

ok, let's complete the variant class with these tools.
In the list below, we've implemented the standard constructor, destructor, move and copy, constructors and assignment operators.
As you can see, when we have the right tools, this is easy.


```cpp
template <typename ... Types>
struct Variant {
	static constexpr auto invalid_index = sizeof...(Types);
	alignas( std::max({alignof(Types)...}) ) char data [ std::max({1ul, sizeof(Types)...}) ];
	int index;

	Variant():index(invalid_index){
	}
	~Variant(){
		destroy();
	}
	Variant(const Variant& v){
		Copy(v);
	}
	Variant& operator= (const Variant& v){
		Copy(v);
		return *this;
	}
	Variant(Variant&& v){
		Move(std::move(v));
	}
	Variant& operator= (Variant&& v){
		Move(std::move(v));
		return *this;
	}

	void Copy(const Variant& v){
		if(index != v.index){
			destroy();
			index = v.index;
			Visit(default_construct_visitor{},*this);
		}
		Visit(copy_visitor{},*this,v);
	}
	void Move(Variant&& v){
		if(index != v.index){
			destroy();
			index = v.index;
			Visit(default_construct_visitor{},*this);
		}
		Visit(move_visitor{},*this,std::move(v));
	}
	void destroy(){
		if(index < invalid_index){
			Visit(destroy_visitor{},*this);
			index = invalid_index;
		}
	}
};

```

We're almost there, but let's add another handy tool so that, we can assign the contents of the variant directly from an object of the underlying type.
so we can write code like this.

```cpp
int main() {
Variant<int,std::string> obj1 = std::string("Hi");
Variant<int,std::string> obj2;

obj2 = 10;
}
```

To do this, we need a pair of template constructor and copy assignment operator as follows:


```cpp
	template <typename T, typename std::enable_if< type_index<std::decay_t<T>, Types...>() < invalid_index , int>::type = 0>
	Variant(T &&val) {
		index = type_index<std::decay_t<T>, Types...>();
		Visit(construct_visitor<std::decay_t<T>,std::decay_t<T>>{std::forward<T>(val)},*this);
	}

	template <typename T, typename std::enable_if< type_index<std::decay_t<T>, Types...>() < invalid_index , int>::type = 0>
	Variant& operator= (T &&val) {
		const auto other_index = type_index<std::decay_t<T>, Types...>();
		if(index != other_index){
			destroy();
			index = other_index;
			Visit(default_construct_visitor{},*this);
		}
		Visit(set_visitor<std::decay_t<T>>{std::forward<T>(val)},*this);
		return *this;
	}

```

As you can see, we have used a universal reference here and we should somehow restrict it, otherwise it matches with everything!

The construct ```std::enable_if``` activates this function if and only if the type "T" matches one of the types in variadic parameters pack ```Types ...```,
We also have to calculate the index of this type "T" among the ```Types ...```. 
The template function ```type_index <T, Types ...> ()``` does this for us and implements it as follows:


```cpp
template<std::size_t Offset,typename Type,typename ...Types>
struct type_index_helper;

template<std::size_t Offset,typename Type,typename Head,typename ... Rests>
struct type_index_helper<Offset,Type,Head,Rests...>{
	static constexpr std::size_t value = type_index_helper<Offset+1,Type,Rests...>::value;
};

template<std::size_t Offset,typename Type,typename ... Rests>
struct type_index_helper<Offset,Type,Type,Rests...>{
	static constexpr std::size_t value = Offset;
};

template<std::size_t Offset,typename Type>
struct type_index_helper<Offset,Type>{
	static constexpr std::size_t value = Offset;
};

template<typename Type,typename ... Types> 
constexpr std::size_t type_index() {
	return type_index_helper<0,Type,Types...>::value;
}

```

So far so good, at the beginning of this post, we assume that all of our types can be default constructible, but we can relax this assumption by writing a non-standard constructor.
We can also implement the "emplace" method function through the non-standard constructor.
Take a look at the following blocks of code:

```cpp
template <typename T, typename ... Ts>
struct construct_visitor {
	std::tuple<Ts...> ts;
	construct_visitor(const Ts& ... ts):ts(ts...){};

	void operator()(T& data) const {
		::new(&data) T(std::get<Ts>(ts)...);
	}

	template <typename U>
	void operator () (U&) const {}
};

template <typename ... Types>
struct Variant {
	static constexpr auto invalid_index = sizeof...(Types);
	alignas( std::max({alignof(Types)...}) ) char data [ std::max({1ul, sizeof(Types)...}) ];
	int index;

	template <typename T, typename ... Ts, typename std::enable_if< type_index<std::decay_t<T>, Types...>() < invalid_index , int>::type = 0 >
	void emplace(Ts&&...vs){
		const auto other_index = type_index<std::decay_t<T>, Types...>();
		if(index != invalid_index){
			destroy();
		}
		index = other_index;
		Visit(construct_visitor<std::decay_t<T>,Ts...>{std::forward<Ts>(vs)...},*this);
	}
};
```

In order to relax the entire variant class and accept all non-default constructibale types, we should also change the above functions for copying and moving elements, but I leave it up to you as a task!
Here is our complete list of variant class visit and visitors.

```cpp
#include <iostream>
#include <algorithm>
#include <type_traits>
#include <functional>
#include <memory>
#include <string>
#include <vector>
#include <cassert>
#include <tuple>

template <typename ... Types>
struct Variant;

///////////////////////////////////////////////////////////////////////////////

template <typename Functor>
using VisitorSignature = void(Functor, void*);

template <typename Functor>
using VisitorSignatureCopy = void(Functor, void*,const void*);

template <typename Functor>
using VisitorSignatureMove = void(Functor, void*, void*);

template <template <typename> class RV,typename Functor, typename ... Types>
struct Visitor {
	static const std::function<VisitorSignature<Functor>> actionArray[sizeof...(Types)];
	static const std::function<VisitorSignatureCopy<Functor>> actionArrayCopy[sizeof...(Types)];
	static const std::function<VisitorSignatureMove<Functor>> actionArrayMove[sizeof...(Types)];

	void visit(Functor functor, Variant<Types...>& obj) const {
		actionArray[obj.index](functor,obj.data);
	}
	void visit(Functor functor, Variant<Types...>& obj1,const Variant<Types...>& obj2) const {
		actionArrayCopy[obj1.index](functor,obj1.data,obj2.data);
	}
	void visit(Functor functor, Variant<Types...>& obj1,Variant<Types...>&& obj2) const {
		actionArrayMove[obj1.index](functor,obj1.data,obj2.data);
	}
};

template <template <typename> class RV,typename Functor, typename ... Types>
const std::function<VisitorSignature<Functor>> Visitor<RV,Functor,Types...>::actionArray[sizeof...(Types)] = {RV<Types>()...};

template <template <typename> class RV,typename Functor, typename ... Types>
const std::function<VisitorSignatureCopy<Functor>> Visitor<RV,Functor,Types...>::actionArrayCopy[sizeof...(Types)] = {RV<Types>()...};

template <template <typename> class RV,typename Functor, typename ... Types>
const std::function<VisitorSignatureMove<Functor>> Visitor<RV,Functor,Types...>::actionArrayMove[sizeof...(Types)] = {RV<Types>()...};

template <typename T>
struct TypeCastVisitor {

	template <typename Functor>
	void operator () (Functor functor, void* data) const {
		functor(*reinterpret_cast<T*>(data));
	}

	template <typename Functor>
	void operator () (Functor functor, void* data1, const void* data2) const {
		functor(*reinterpret_cast<T*>(data1),*reinterpret_cast<const T*>(data2));
	}

	template <typename Functor>
	void operator () (Functor functor, void* data1, void* data2) const {
		functor(*reinterpret_cast<T*>(data1),static_cast<T&&>(*reinterpret_cast<T*>(data2)));
	}
};

template <typename ... Types, typename Functor>
void Visit(Functor functor, Variant<Types...>& obj){
	Visitor<TypeCastVisitor,Functor,Types...> visitor;
	visitor.visit(functor,obj);
}
template <typename ... Types, typename Functor>
void Visit(Functor functor, Variant<Types...>& obj1,const Variant<Types...>& obj2){
	Visitor<TypeCastVisitor,Functor,Types...> visitor;
	visitor.visit(functor,obj1,obj2);
}
template <typename ... Types, typename Functor>
void Visit(Functor functor, Variant<Types...>& obj1,Variant<Types...>&& obj2){
	Visitor<TypeCastVisitor,Functor,Types...> visitor;
	visitor.visit(functor,obj1,std::move(obj2));
}

///////////////////////////////////////////////////////////////////////////////

struct default_construct_visitor {
	template <typename T>
	void operator()(T& data) const {
		::new(&data) T();
	}
};

template <typename T, typename ... Ts>
struct construct_visitor {
	std::tuple<Ts...> ts;
	construct_visitor(const Ts& ... ts):ts(ts...){};

	void operator()(T& data) const {
		::new(&data) T(std::get<Ts>(ts)...);
	}

	template <typename U>
	void operator () (U&) const {}
};

struct destroy_visitor {
	template <typename T>
	void operator()(T& data) const {
		data.~T();
	}
};

template <typename T>
struct set_visitor {
	T temp;
	set_visitor(const T& temp):temp(temp){}
	void set(const T& t){ temp = t; }

	void operator()(T& data) const {
		data =  temp;
	}

	template <typename U>
	void operator () (U&) const {}
};

struct copy_visitor {
	template <typename T>
	void operator()(T& data1,const T& data2) const {
		data1 =  data2;
	}
};

struct move_visitor {
	template <typename T>
	void operator()(T& data1,T&& data2) const {
		data1 =  std::move(data2);
	}
};

///////////////////////////////////////////////////////////////////////////////

template<std::size_t Offset,typename Type,typename ...Types>
struct type_index_helper;

template<std::size_t Offset,typename Type,typename Head,typename ... Rests>
struct type_index_helper<Offset,Type,Head,Rests...>{
	static constexpr std::size_t value = type_index_helper<Offset+1,Type,Rests...>::value;
};

template<std::size_t Offset,typename Type,typename ... Rests>
struct type_index_helper<Offset,Type,Type,Rests...>{
	static constexpr std::size_t value = Offset;
};

template<std::size_t Offset,typename Type>
struct type_index_helper<Offset,Type>{
	static constexpr std::size_t value = Offset;
};

template<typename Type,typename ... Types> 
constexpr std::size_t type_index() {
	return type_index_helper<0,Type,Types...>::value;
}

///////////////////////////////////////////////////////////////////////////////

template <typename ... Types>
struct Variant {
	static constexpr auto invalid_index = sizeof...(Types);
	alignas( std::max({alignof(Types)...}) ) char data [ std::max({1ul, sizeof(Types)...}) ];
	int index;

	Variant():index(invalid_index){
	}
	~Variant(){
		destroy();
	}
	Variant(const Variant& v){
		Copy(v);
	}
	Variant& operator= (const Variant& v){
		Copy(v);
		return *this;
	}
	Variant(Variant&& v){
		Move(std::move(v));
	}
	Variant& operator= (Variant&& v){
		Move(std::move(v));
		return *this;
	}

	template <typename T, typename std::enable_if< type_index<std::decay_t<T>, Types...>() < invalid_index , int>::type = 0>
	Variant(T &&val) {
		index = type_index<std::decay_t<T>, Types...>();
		Visit(construct_visitor<std::decay_t<T>,std::decay_t<T>>{std::forward<T>(val)},*this);
	}

	template <typename T, typename std::enable_if< type_index<std::decay_t<T>, Types...>() < invalid_index , int>::type = 0>
	Variant& operator= (T &&val) {
		const auto other_index = type_index<std::decay_t<T>, Types...>();
		if(index != other_index){
			destroy();
			index = other_index;
			Visit(default_construct_visitor{},*this);
		}
		Visit(set_visitor<std::decay_t<T>>{std::forward<T>(val)},*this);
		return *this;
	}

	template <typename T, typename ... Ts, typename std::enable_if< type_index<std::decay_t<T>, Types...>() < invalid_index , int>::type = 0 >
	void emplace(Ts&&...vs){
		const auto other_index = type_index<std::decay_t<T>, Types...>();
		if(index != invalid_index){
			destroy();
		}
		index = other_index;
		Visit(construct_visitor<std::decay_t<T>,Ts...>{std::forward<Ts>(vs)...},*this);
	}

	void Copy(const Variant& v){
		if(index != v.index){
			destroy();
			index = v.index;
			Visit(default_construct_visitor{},*this);
		}
		Visit(copy_visitor{},*this,v);
	}
	void Move(Variant&& v){
		if(index != v.index){
			destroy();
			index = v.index;
			Visit(default_construct_visitor{},*this);
		}
		Visit(move_visitor{},*this,std::move(v));
	}
	void destroy(){
		if(index < invalid_index){
			Visit(destroy_visitor{},*this);
			index = invalid_index;
		}
	}
};

int main(){
	Variant<int,std::string> obj1 = std::string("Hi");
	Variant<int,std::string> obj2;

	obj2=10;

	Visit([](auto& data){std::cout << data << std::endl;}
	,obj1);

	Visit([](auto& data){std::cout << data << std::endl;}
	,obj2);


	obj2 = std::move(obj1);

	Visit([](auto& data){std::cout << data << std::endl;}
	,obj1);

	Visit([](auto& data){std::cout << data << std::endl;}
	,obj2);


	obj1.emplace<std::string>(5,'x');
	Visit([](auto& data){std::cout << data << std::endl;}
	,obj1);
}

```
## References
* [Everything You Need to Know About std::variant from C++17 ](https://www.bfilipek.com/2018/06/variant.html)
* [std::variant Doesn't Let Me Sleep](https://pabloariasal.github.io/2018/06/26/std-variant/)
* [Variadic templates: how I wrote a variant class](https://thenewcpp.wordpress.com/2012/02/15/variadic-templates-part-3-or-how-i-wrote-a-variant-class/)
* [My take on variant](https://foonathan.net/2016/12/variant/)
* [Standardizing Variant: Difficult Decisions](https://www.justsoftwaresolutions.co.uk/cplusplus/standardizing-variant.html)
* [N4542: Variant: a type safe union (v4)](http://open-std.org/JTC1/SC22/WG21/docs/papers/2015/n4542.pdf)


