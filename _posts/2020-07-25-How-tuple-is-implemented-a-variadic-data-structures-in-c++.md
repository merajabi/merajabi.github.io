---
layout: post
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

Let's call our tuple "DataStructure". First we define the general "DataStructure" and then a specialization. In a special structure we define a variable "head" of the first type and a variable "rests" of the same DataStructure, but with the rest of the types. and that's it.

We created a variable type DataStructure. Then we can define our first variable from this type.

Before we proceed, however, we should define a different specification. If there is only one type left in the "Rests" group, the only member of the final structure is that type.

```cpp

template<typename ...Ts>
struct DataStructure;

template<typename Head, typename ...Rests>
struct DataStructure<Head,Rests...>{
	Head head;
	DataStructure<Rests...> rests;
};

template<typename Head>
struct DataStructure<Head>{
	Head head;
};

int main() {
	DataStructure<int, float, std::string> var = {1, 2.1, std::string("Hello")};
	std::cout << var.head << std::endl;
}

```

Of course we can access the internal attribute like this ```var.head``` or ```var.rests.head```, but it's noisy, so we'll implement a helper to make it easy, like ```std::get```.

Here we define a generic "IdHelper" and call it recursively. With each call, we decrement "idx" by one until "idx" becomes zero, and in this case the specified version of struct returns the main member of "DataStructure".

If you compile the code with C++14, you can omit this ```-> decltype(...)``` at the end of the get signature.

```cpp
template<int idx, typename Head, typename ...Rests>
struct IdHelper{
	static auto get(DataStructure<Head,Rests...>& data) -> decltype(IdHelper<idx-1,Rests...>::get(data.rests)) {
		return IdHelper<idx-1,Rests...>::get(data.rests);
	}
};

template<typename Head, typename ...Rests>
struct IdHelper<0,Head,Rests...>{
	static auto get(DataStructure<Head,Rests...>& data) -> decltype(data.head) {
		return data.head;
	}
};

int main() {
	DataStructure<int, float, std::string> var = {1, 2.1, std::string("Hello")};
	std::cout << IdHelper<2,int, float, std::string>::get(var) << std::endl;
}


```

OK, how get rid of these templates types when we call ```IdHelper::get```? Simple, we call it using a template function.


```cpp

template<int idx,typename ...Ts>
auto get(DataStructure<Ts...>& var) -> decltype(IdHelper<idx,Ts...>::get(var)) {
	return IdHelper<idx,Ts...>::get(var);
}

int main() {
	DataStructure<int, float, std::string> var = {1, 2.1, std::string("Hello")};
	std::cout << get<2>(var) << std::endl;
}

```

In the same way we can implement a helper structure and function to get the value by type. This time specialization is called when the type we provide is identical to one of the DataStructure types.

```cpp

template<typename type, typename Head, typename ...Rests>
struct TypeHelper{
	static auto get(DataStructure<Head,Rests...>& data) -> decltype(TypeHelper<type,Rests...>::get(data.rests)) {
		return TypeHelper<type,Rests...>::get(data.rests);
	}
};

template<typename type, typename ...Rests>
struct TypeHelper<type,type,Rests...>{
	static auto get(DataStructure<type,Rests...>& data) -> decltype(data.head) {
		return data.head;
	}
};


template<typename type,typename ...Ts>
auto get(DataStructure<Ts...>& var) -> decltype(TypeHelper<type,Ts...>::get(var)) {
	return TypeHelper<type,Ts...>::get(var);
}

int main() {
	DataStructure<int, float, std::string> var = {1, 2.1, std::string("Hello")};
	std::cout << get<int>(var) << std::endl;
}

```
We can continue to implement various constructors and operators, but this is a foundation.

## How to implement tuples using inheritance
to be continued ...


