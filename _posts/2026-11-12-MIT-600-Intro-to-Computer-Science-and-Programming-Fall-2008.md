---
layout: post
comments: true
title: MIT 6.00 Intro to Computer Science & Programming; Fall 2008
tags: [optimization problems, dynamic programming, memoization, 0-1 Knapsack Problem, Python]
color: black
author: Ryan
feature-img: "assets/img/pexels/pexels-expected-1920x1280.jpg"
thumbnail: "assets/thumbnails/pexels/pexels-expected-960x640.jpg"
categories: [cs-courses]
excerpt_separator: <!--more-->
---

Designed for beginners with little to no coding experience, this Python-based course builds your confidence in using computation to solve real-world problems. It equips students from any background with the practical skills to write useful programs.

**Instructors:** Prof. Eric Grimson, Prof. John Guttag 

<!--more-->

**Table of Contents**
* TOC
{:toc}



### 1. The Problem with Naive Recursion (Overlapping Sub-problems)

* **The Fibonacci Example:** The professor starts by reviewing a recursive implementation of the Fibonacci sequence. Running `fib(6)` takes 25 recursive calls because the function repeatedly computes the exact same values on different branches (known as **overlapping sub-problems**).
* **Exponential Growth:** Without optimization, the number of calls grows exponentially, making larger computations completely infeasible.

### 2. Memoization and Dynamic Programming

* **Memoization:** To fix redundant computations, the professor introduces memoization—a technique where results are stored (e.g., in a Python dictionary) the first time they are calculated and looked up thereafter.
* **Massive Performance Boost:** Implementing a memoized version (`fastFib`) dramatically reduces the number of calls (e.g., dropping millions of calls down to just a handful) and forms the foundation of **dynamic programming**.

### 3. Requirements for Dynamic Programming

To successfully apply dynamic programming to a problem, two conditions must be met:

1. **Overlapping Sub-problems:** The problem can be broken down into smaller instances that share common sub-problems.
2. **Optimal Substructure:** A globally optimal solution can be constructed from locally optimal solutions of its sub-problems.

### 4. The 0-1 Knapsack Problem

* **The Challenge:** Given a set of items with specific weights and values, find the subset that maximizes total value without exceeding a given weight constraint.
* **Brute-Force & Decision Trees:** A naive approach involves constructing a binary decision tree (whether to "take" or "not take" an item) and evaluating all $2^n$ possible subsets. This approach also leads to exponential time complexity (millions of calls for relatively small datasets).
* **Optimizing the Knapsack:** By applying memoization to the recursive decision tree (`fast max val`), the professor demonstrates a staggering performance improvement—reducing 17 million brute-force calls down to less than 2,000 calls while yielding the correct optimal result.
