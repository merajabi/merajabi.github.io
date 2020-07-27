---
layout: post
comments: true
title: How tuple is implemented, A variadic data structures in c++
tags: [tuple, variadic, data structure, C++]
color: black
author: raha
feature-img: "assets/img/pexels/computer.jpeg"
thumbnail: "assets/thumbnails/pexels/computer-960x640.jpg"
category: programming/CPP
excerpt_separator: <!--more-->
---

Have you ever wished you could return more than one item from a function?
```std::tuple``` is the answer!

<!--more-->

You can say that good design can solve the problem and I agree, in some cases it will.

Still, there is a situation where this need is so temporary that there is no point in changing the design. Passing a reference as an argument is always an option, but I'm assuming that updating function arguments will make the code less readable.

Finally, why should we learn how the feature is implemented? Because, When we know how different features of the language are implemented, we learn nuances and tricks of the language that will help us to write cleaner and more generic code in the future.

### How to use tuples in c++11

Using ```std::tuple``` is easy, indicate the required types and you're done.
You can use the brace initialization or ```std::make_tuple```.

```cpp
std::tuple<int, float, std::string> data1 = {1, 2.1, std::string("Hello")};
auto data2 = std::make_tuple(1, 2.1, std::string("Hello"));

std::cout << std::get<0>(data1) << std::endl;
std::cout << std::get<1>(data1) << std::endl;

std::cout << std::get<2>(data2) << std::endl;
std::cout << std::get<0>(data2) << std::endl;

```

Now suppose we have a function that returns a tuple. We can save the tuple and use it later, or save every part of the data structure in "tied" variables.

```cpp
auto func() -> std::tuple<double,std::string> {
	double x = 3.1415;
	std::string s = "hello";
	return std::make_tuple(x,s);
}

int main() {
	auto data = func();

	std::cout << std::get<0>(data) << std::endl;
	std::cout << std::get<1>(data) << std::endl;

	double x;
	std::string str;
	std:tie(x,str) = func();

	std::cout << x << std::endl;
	std::cout << str << std::endl;
}

```

me too! I don't like this ``` -> decltype(...) ``` at the end of the function signature in C++11, hopefully we don't need it in C++14 anymore :)

### How to use tuples in c++14

In C++11, you can only access the member through the index, but in C++14 you can also access the members by type, and even better, the function can be written cleaner.

```cpp
auto func() {
	double x = 3.1415;
	std::string s = "hello";
	return std::make_tuple(x,s);
}

int main() {
	auto data = func();

	std::cout << std::get<0>(data) << std::endl;
	std::cout << std::get<double>(data) << std::endl;

	std::cout << std::get<1>(data) << std::endl;
	std::cout << std::get<std::string>(data) << std::endl;

	double x;
	std::string str;
	std:tie(x,str) = func();

	std::cout << x << std::endl;
	std::cout << str << std::endl;
}

```


## How to implement tuples recursively

ok in this part i will say how ```std::tuple``` could be implemented under the hood.

Let's call our tuple "Tuple" with big T to distinguish it from ```std::tuple```. First we define the general "Tuple" and then a specialization. In a special structure we define a variable "head" of the first type and a variable "rests" of the same Tuple, but with the rest of the types. and that's it.

We created a variable type Tuple. Then we can define our first variable from this type.

Before we proceed, however, we should define a different specification. If there is only one type left in the "Rests" group, the only member of the final structure is that type.

```cpp

template<typename ...Ts>
struct Tuple;

template<typename Head, typename ...Rests>
struct Tuple<Head,Rests...>{
	Head head;
	Tuple<Rests...> rests;
};

template<typename Head>
struct Tuple<Head>{
	Head head;
};

int main() {
	Tuple<int, float, std::string> var = {1, 2.1, std::string("Hello")};
	std::cout << var.head << std::endl;
}

```

Of course we can access the internal attribute like this ```var.head``` or ```var.rests.head```, but it's noisy, so we'll implement a helper to make it easy, like ```std::get```.

Here we define a generic "IdHelper" and call it recursively. With each call, we decrement "idx" by one until "idx" becomes zero, and in this case the specified version of struct returns the main member of "Tuple".

If you compile the code with C++14, you can omit this ```-> decltype(...)``` at the end of the get signature.

```cpp
template<int idx, typename Head, typename ...Rests>
struct IdHelper{
	static auto get(Tuple<Head,Rests...>& data) -> decltype(IdHelper<idx-1,Rests...>::get(data.rests)) {
		return IdHelper<idx-1,Rests...>::get(data.rests);
	}
};

template<typename Head, typename ...Rests>
struct IdHelper<0,Head,Rests...>{
	static auto get(Tuple<Head,Rests...>& data) -> decltype(data.head) {
		return data.head;
	}
};

int main() {
	Tuple<int, float, std::string> var = {1, 2.1, std::string("Hello")};
	std::cout << IdHelper<2,int, float, std::string>::get(var) << std::endl;
}


```

OK, how get rid of these templates types when we call ```IdHelper::get```? Simple, we call it using a template function.


```cpp

template<int idx,typename ...Ts>
auto get(Tuple<Ts...>& var) -> decltype(IdHelper<idx,Ts...>::get(var)) {
	return IdHelper<idx,Ts...>::get(var);
}

int main() {
	Tuple<int, float, std::string> var = {1, 2.1, std::string("Hello")};
	std::cout << get<2>(var) << std::endl;
}

```

In the same way we can implement a helper structure and function to get the value by type. This time specialization is called when the type we provide is identical to one of the Tuple types.

```cpp

template<typename type, typename Head, typename ...Rests>
struct TypeHelper{
	static auto get(Tuple<Head,Rests...>& data) -> decltype(TypeHelper<type,Rests...>::get(data.rests)) {
		return TypeHelper<type,Rests...>::get(data.rests);
	}
};

template<typename type, typename ...Rests>
struct TypeHelper<type,type,Rests...>{
	static auto get(Tuple<type,Rests...>& data) -> decltype(data.head) {
		return data.head;
	}
};


template<typename type,typename ...Ts>
auto get(Tuple<Ts...>& var) -> decltype(TypeHelper<type,Ts...>::get(var)) {
	return TypeHelper<type,Ts...>::get(var);
}

int main() {
	Tuple<int, float, std::string> var = {1, 2.1, std::string("Hello")};
	std::cout << get<int>(var) << std::endl;
}

```

the complelete listing of our work is as follow

```cpp
#include <iostream>
#include <tuple>
#include <type_traits>

template<typename ...Ts>
struct Tuple;

template<int idx, typename Head, typename ...Rests>
struct IdHelper{
	static auto get(Tuple<Head,Rests...>& data) -> decltype(IdHelper<idx-1,Rests...>::get(data.rests)) {
		return IdHelper<idx-1,Rests...>::get(data.rests);
	}
};

template<typename Head, typename ...Rests>
struct IdHelper<0,Head,Rests...>{
	static auto get(Tuple<Head,Rests...>& data) -> decltype(data.head) {
		return data.head;
	}
};

template<typename type, typename Head, typename ...Rests>
struct TypeHelper{
	static auto get(Tuple<Head,Rests...>& data) -> decltype(TypeHelper<type,Rests...>::get(data.rests)) {
		return TypeHelper<type,Rests...>::get(data.rests);
	}
};

template<typename type, typename ...Rests>
struct TypeHelper<type,type,Rests...>{
	static auto get(Tuple<type,Rests...>& data) -> decltype(data.head) {
		return data.head;
	}
};


template<typename Head, typename ...Rests>
struct Tuple<Head,Rests...>{
	Head head;
	Tuple<Rests...> rests;
};

template<typename Head>
struct Tuple<Head>{
	Head head;
};

template<int idx,typename ...Ts>
auto get(Tuple<Ts...>& var) -> decltype(IdHelper<idx,Ts...>::get(var)) {
	return IdHelper<idx,Ts...>::get(var);
}

template<typename type,typename ...Ts>
auto get(Tuple<Ts...>& var) -> decltype(TypeHelper<type,Ts...>::get(var)) {
	return TypeHelper<type,Ts...>::get(var);
}

int main()
{
	{
		Tuple<int, float, std::string> var = {1, 2.1, std::string("Hello")};
		std::cout << IdHelper<2,int, float, std::string>::get(var) << std::endl;
		std::cout << get<2>(var) << std::endl;
		std::cout << get<int>(var) << std::endl;
	}
	{
		Tuple<int, float, std::string> data1 = {1, 2.1, std::string("Hello")};
		Tuple<int, float, std::string> data2 = data1;
		Tuple<int, float, std::string> data3;

		data3=data2;
		std::cout << get<0>(data3) << std::endl;
		std::cout << get<1>(data3) << std::endl;
		std::cout << get<2>(data3) << std::endl;

		Tuple<int, float, std::string> data4(Tuple<int, float, std::string>{1, 2.1, std::string("Hello")});

		std::cout << get<int>(data4) << std::endl;
		std::cout << get<float>(data4) << std::endl;
		std::cout << get<std::string>(data4) << std::endl;
	} 
    return 0;
}
```
### How to implement std::tie

As you can see at the beginning of this discussion, one of the features of ```std::tuple``` was its ease of use with ```std::tie``` to get a set of returned values ​​from a function.
So we will continue to implement ties for our Tuple class.

Tie could easily be implemented as follows.
We instantiate the tuple class with the reference type and then bind the class attribute to the external object by entering lvalue reference as the constructor parameter.
If we later assign this tuple, these references will be updated before the temporary tuple object goes out of scope and is destroyed. This is the first trick.


```cpp
template<typename ...Ts>
auto Tie(Ts& ... args) -> Tuple<Ts& ...> {
	return Tuple<Ts& ...>(args...) ;
}

auto func() -> Tuple<double,std::string> {
	double x = 3.1415;
	std::string s = "hello";
	return Tuple<double,std::string>(x,s);
}

int main() {
	double x;
	std::string str;
	Tie(x,str) = func();

	std::cout << x << std::endl;
	std::cout << str << std::endl;
	return 0;
}
```

But we should actually write a constructor that takes a variadic list of arguments and generates the Tuple object.
We haven't done that before. We only initialized our tuple with braces and used standard compiler-generated constructors.

Our new constructors may look like this, but we're not quite there yet!

```cpp

template<typename Head, typename ...Rests>
struct Tuple<Head,Rests...>{
	Head head;
	Tuple<Rests...> rests;

	Tuple():head(),rests(){};

	Tuple(const Head& head, const Rests&... rests)
		: head(head)
		, rests(rests...)
	{}

	Tuple(Head& head, Rests&... rests)
		: head(head)
		, rests(rests...)
	{}
};
```

If you initialize Tuple with something like ```int&``` or ```T&``` to have a reference attribute, the constructor signature changes to ```const Head &&``` or ```Head&&```. We didn't like that, so we need a little more work here.

we should remove all type qualifiers and then add what is necessary. Therefore, we first define some tools as follows. some of these are added in c++14 but I will write the code to be compatible with c++11.

```cpp

template<typename T>
using add_lref_t = typename std::add_lvalue_reference<T>::type; // add lvalue reference

template<typename T>
using add_clref_t = add_lref_t< typename std::add_const<T>::type >; // add const lvalue reference

template<typename T>
using remove_cvref_t = typename std::remove_cv<typename std::remove_reference<T>::type>::type; // remove any const volatile or reference

template<typename T>
using decay_t = typename std::decay<T>::type;

```

Now we can rewrite the Tuple implementation as follows

```cpp

template<typename Head, typename ...Rests>
struct Tuple<Head,Rests...>{
	Head head;
	Tuple<Rests...> rests;

	Tuple():head(),rests(){};

	Tuple(add_clref_t<remove_cvref_t<Head>> head, add_clref_t<remove_cvref_t<Rests>>... rests)
		: head(head)
		, rests(rests...)
	{}

	Tuple(add_lref_t<Head> head, add_lref_t<Rests> ... rests)
		: head(head)
		, rests(rests...)
	{}
};

template<typename Head>
struct Tuple<Head>{
	Head head;

	Tuple():head(){};

	Tuple(add_clref_t<remove_cvref_t<Head>> head)
		: head(head)
	{}
	Tuple(add_lref_t<Head> head)
		: head(head)
	{}
};

```

Ok, we're almost there, but we still need a tool.
Take a look at the line in which we assign the return value of the "func" function to the "Tie" function.
The return value of func is usually ``` Tuple <Ts ...>```, but the return value of "Tie" is of the type ``` Tuple <Ts & ...> ```.
We should do something about it. These types are not the same, so we cannot use the compiler-generated copy assignment.

Well, we should overload the default copy assignment operator. but we should be careful, if we write it too general, we will screw it up !!

One way to write this function is as follows.
This function is only activated if we have two "Tuples" and for each type ```head``` in ```this``` and ```NHead``` in ```other``` the decay of "head" and "NHead" must be the same.
by the way, this was the second trick in this implementation ;)

```cpp
template<typename NHead, typename ...NRests,  typename std::enable_if< std::is_same< decay_t<NHead>,decay_t<Head> >::value , int>::type = 0 >
Tuple& operator=(const Tuple<NHead,NRests...>& other){
	head = other.head;
	rests = other.rests;
	return *this;
}

```

Well, the next listing is a full Tuple implementation with Tie that is compatible with c++11. In C++14 we don't need those ```->``` at the end of the auto functions.

```cpp
#include <iostream>
#include <tuple>
#include <type_traits>

template<typename T>
using add_lref_t = typename std::add_lvalue_reference<T>::type;

template<typename T>
using add_clref_t = add_lref_t< typename std::add_const<T>::type >;

template<typename T>
using remove_cvref_t = typename std::remove_cv<typename std::remove_reference<T>::type>::type;

template<typename T>
using decay_t = typename std::decay<T>::type;

template<typename ...Ts>
struct Tuple;

template<int idx, typename Head, typename ...Rests>
struct IdHelper{
	static auto get(Tuple<Head,Rests...>& data) -> decltype(IdHelper<idx-1,Rests...>::get(data.rests)) {
		return IdHelper<idx-1,Rests...>::get(data.rests);
	}
};

template<typename Head, typename ...Rests>
struct IdHelper<0,Head,Rests...>{
	static auto get(Tuple<Head,Rests...>& data) -> decltype(data.head) {
		return data.head;
	}
};

template<typename type, typename Head, typename ...Rests>
struct TypeHelper{
	static auto get(Tuple<Head,Rests...>& data) -> decltype(TypeHelper<type,Rests...>::get(data.rests)) {
		return TypeHelper<type,Rests...>::get(data.rests);
	}
};

template<typename type, typename ...Rests>
struct TypeHelper<type,type,Rests...>{
	static auto get(Tuple<type,Rests...>& data) -> decltype(data.head) {
		return data.head;
	}
};


template<typename Head, typename ...Rests>
struct Tuple<Head,Rests...>{
	Head head;
	Tuple<Rests...> rests;

	Tuple():head(),rests(){};

	Tuple(add_clref_t<remove_cvref_t<Head>> head, add_clref_t<remove_cvref_t<Rests>>... rests)
		: head(head)
		, rests(rests...)
	{}

	Tuple(add_lref_t<Head> head, add_lref_t<Rests> ... rests)
		: head(head)
		, rests(rests...)
	{}

	template<typename NHead, typename ...NRests,  typename std::enable_if< std::is_same< decay_t<NHead>,decay_t<Head> >::value , int>::type = 0 >
	Tuple& operator=(const Tuple<NHead,NRests...>& ds){
		head = ds.head;
		rests = ds.rests;
		return *this;
	}
};

template<typename Head>
struct Tuple<Head>{
	Head head;

	Tuple():head(){};

	Tuple(add_clref_t<remove_cvref_t<Head>> head)
		: head(head)
	{}
	Tuple(add_lref_t<Head> head)
		: head(head)
	{}

	template<typename NHead,  typename std::enable_if< std::is_same<decay_t<NHead>,decay_t<Head>>::value , int>::type = 0 >
	Tuple& operator=(const Tuple<NHead>& ds){
		head = ds.head;
		return *this;
	}

};

template<int idx,typename ...Ts>
auto get(Tuple<Ts...>& var) -> decltype(IdHelper<idx,Ts...>::get(var)) {
	return IdHelper<idx,Ts...>::get(var);
}

template<typename type,typename ...Ts>
auto get(Tuple<Ts...>& var) -> decltype(TypeHelper<type,Ts...>::get(var)) {
	return TypeHelper<type,Ts...>::get(var);
}

template<typename ...Ts>
auto Tie(Ts& ... args) -> Tuple<Ts& ...> {
	return Tuple<Ts& ...>(args...) ;
}

auto func() -> Tuple<double,std::string> {
	double x = 3.1415;
	std::string s = "hello";
	return Tuple<double,std::string>(x,s);
}

int main()
{
	auto data = func();
	std::cout << get<double>(data) << std::endl;
	std::cout << get<std::string>(data) << std::endl;

	double x;
	std::string str;
	Tie(x,str) = func();

	std::cout << x << std::endl;
	std::cout << str << std::endl;
	return 0;
}
```

We can continue to implement various constructors and operators, but this is a foundation.


## How to implement tuples using inheritance
to be continued ...

## References

* [riptutorial](https://riptutorial.com/cplusplus/example/19276/variadic-template-data-structures)
* [mitchnull](https://mitchnull.blogspot.com/2012/06/c11-tuple-implementation-details-part-1.html)

