---
layout: post
comments: true
title: Using and Implementing expected and unexpected with std::variant
tags: [expected, unexpected, union, variant, C++]
color: black
author: raha
feature-img: "assets/img/pexels/pexels-skitterphoto-1920x1280.jpg"
thumbnail: "assets/thumbnails/pexels/pexels-skitterphoto-960x640.jpg"
category: programming/CPP
excerpt_separator: <!--more-->
---

This guide explains why expected is useful, what its structure looks like, and how you can implement it yourself.
<!--more-->
We will also look at the main challenges of building such types, and I will walk you through how each step works in the provided implementation.

Table of Contents
* TOC
{:toc}

## Why Use `expected`?

`expected` is a type that can hold either a **successful result** or an **error**. This lets you return errors in a safer way instead of throwing exceptions or using error codes. When a function returns `expected<T, E>`, you can check if it has a valid value (`T`) or an error (`E`) before using it.

This approach makes error handling more **explicit**. You won’t forget to check for errors because you must query the object to get the result. It also helps avoid hidden control flow surprises that often come with exceptions.

---

## General Structure of `expected` and `unexpected`

In this implementation, `expected<T, E>` is built on top of `std::variant`. The `variant` holds either the success value of type `T` or an `unexpected<E>` containing the error. This gives you a single object that clearly shows which state it’s in.

The `unexpected` type itself is simple: it only wraps the error value. It acts as a tagged container to signal that there was a failure. You can access the error directly when needed.

```cpp
template<class E>
class unexpected;

template<class T, class E>
class expected {
    using storage_t = std::variant<T, unexpected<E>>;
    storage_t storage_;

    ...
};
```

---

## Main Challenges in Writing These Types

One challenge is **correctly managing the two states**—either success or error—and ensuring that only the right functions are accessible in each state. For example, you don’t want to call `value()` if the object contains an error. This is enforced with runtime checks (`MR_ASSERT`).

```cpp
#ifndef MR_ASSERT
#define MR_ASSERT(cond) if (!(cond)) { throw std::logic_error("assertion failure"); }
#endif
```

Another challenge is making the interface **easy to use**. The class must provide operators like `*`, `->`, and functions like `value_or()` so users can get the contained value safely. Supporting all combinations of copy, move, and in-place construction also requires careful design.

---

## Detailed Explanation of Each Part

Below, I’ll go step by step through the important pieces of the code and explain how they work.

---

### 1. Tag Types (`unexpect_t` and `in_place_t`)

These small types (`unexpect_t` and `in_place_t`) are used as **tags** to tell the constructor which state you want to create. For example, `unexpect` signals that you want to construct the object in the error state. `in_place` is used to build the success value directly.

Using tags avoids confusion in overloaded constructors and makes intent very clear to the caller.

```cpp
struct unexpect_t { explicit unexpect_t() = default; };
struct in_place_t  { explicit in_place_t()  = default; };

inline constexpr unexpect_t unexpect{};
inline constexpr in_place_t  in_place{};
```

---

### 2. The `unexpected<E>` Class

This type holds only the error. It provides constructors to initialize the error from a copy or move. The `error()` function lets you access the error safely. There is also a `make_unexpected()` helper to create an `unexpected` easily.

This class is simple on purpose: it exists only to store and convey the error.
```cpp
template<class E>
class unexpected {
public:
    unexpected() = delete;
    unexpected(const E& e) : err_(e) {}
    unexpected(E&& e)      : err_(std::move(e)) {}

    // defaults for copy/move/destruct:
    ...

    const E& error() const & { return err_; }
          E& error() &       { return err_; }

private:
    E err_;
};
```

---

### 3. `expected<T, E>` Constructor Logic

The `expected` class has many constructors to cover all scenarios. For example, you can default-construct it (if `T` is default-constructible), pass a `T` value to create a success, or use `unexpect` and an `E` to create an error.

Internally, it uses `std::variant<T, unexpected<E>>` to store one of the two possibilities. The constructors call `std::in_place_index_t<N>` to tell the variant which alternative to create.

```cpp
    template <typename U = T,
              typename = std::enable_if_t<std::is_default_constructible_v<U>>>
    expected() : storage_(std::in_place_index_t<0>{}) {}

    expected(const T& v) : storage_(std::in_place_index_t<0>{}, v) {}
    expected(T&& v) : storage_(std::in_place_index_t<0>{}, std::move(v)) {}

    expected(unexpect_t, const E& e)
        : storage_(std::in_place_index_t<1>{}, e) {}
    expected(unexpect_t, E&& e)
        : storage_(std::in_place_index_t<1>{}, std::move(e)) {}

    expected(const unexpected<E>& u)
        : storage_(std::in_place_index_t<1>{}, u) {}
    expected(unexpected<E>&& u)
        : storage_(std::in_place_index_t<1>{}, std::move(u)) {}

```
---

### 4. State Query (`has_value()`)

The `has_value()` function checks whether the stored index is `0`, which means the object holds a `T`. This check is used everywhere to ensure that operations on the value are safe.

When you write `if (exp)`, it calls the `operator bool()`, which uses `has_value()`. This makes it easy to check the success state in your code.

```cpp
    explicit operator bool() const noexcept { return has_value(); }
    bool has_value() const noexcept { return storage_.index() == 0; }
```

---

### 5. Accessing the Value

Operators like `*` and `->` let you get the stored `T` just like you would with a pointer or optional. The `value()` function returns a reference to the stored value.

Before accessing, these functions assert that the object really has a value. If not, `MR_ASSERT` throws an exception. This prevents misuse.

```cpp

    // value access
    T& operator*() & {
        MR_ASSERT(has_value());
        return *std::get_if<0>(&storage_);
    }

    T&& operator*() && {
        MR_ASSERT(has_value());
        return std::get<0>(std::move(storage_));
    }

    T& value() & {
        MR_ASSERT(has_value());
        return *std::get_if<0>(&storage_);
    }

    T&& value() && {
        MR_ASSERT(has_value());
        return std::get<0>(std::move(storage_));
    }

```
---

### 6. Accessing the Error

If the object is in the error state, you can call `error()` to get the stored error reference. Just like value access, these functions assert that the object is actually in the error state.

This clear separation makes it impossible to confuse success and failure at runtime if you always check properly.

```cpp
    E& error() & {
        MR_ASSERT(!has_value());
        return std::get<1>(storage_).error();
    }
    const E& error() const & {
        MR_ASSERT(!has_value());
        return std::get<1>(storage_).error();
    }
```
---

### 7. Emplacing a New Value

The `emplace()` functions let you destroy the current contents and build a new value of `T` in place. This is useful when you want to reuse an `expected` object without creating a new one.

These functions forward arguments to the `std::variant` `emplace`, which reconstructs the value efficiently.

```cpp
    template<class... Args>
    void emplace(Args&&... args) {
        storage_.template emplace<0>(std::forward<Args>(args)...);
    }

    template<class U, class... Args>
    void emplace(std::initializer_list<U> il, Args&&... args) {
        storage_.template emplace<0>(il, std::forward<Args>(args)...);
    }
```

---

### 8. Specialization for `void`

If `T` is `void`, you don’t need to store any value, only the error state. In this case, the implementation uses `std::variant<std::monostate, unexpected<E>>`. The API still lets you check success and get the error when needed.

The `value()` function for `void` simply checks the state but does nothing because there is no data to return.

```cpp
template<class E>
class expected<void, E> {
    using storage_t = std::variant<std::monostate, unexpected<E>>;
    storage_t storage_{std::in_place_index_t<0>{}};
    ...
};
```

---

## Conclusion

This implementation gives you a clear and reliable way to return success or error without exceptions. The design uses modern C++ features like `std::variant` and in-place construction to make the code clean and safe. By understanding each part, you can adapt it to fit your own projects.

If you want to use `expected` in your code, start by returning it instead of throwing, and always check `has_value()` before accessing the result.


## References
* [SimpleExpected](https://github.com/merajabi/simple-expected)
