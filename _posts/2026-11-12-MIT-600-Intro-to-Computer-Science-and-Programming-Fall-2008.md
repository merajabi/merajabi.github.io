---
layout: post
comments: true
title: MIT 6.00 Intro to Computer Science & Programming - Fall 2008
tags: [optimization problems, dynamic programming, memoization, 0-1 Knapsack Problem, Python]
color: black
author: Ryan
feature-img: "assets/img/pexels/mit-600-intro-to-cs.webp"
thumbnail: "assets/thumbnails/pexels/mit-600-intro-to-cs-960x640.jpg"
categories: [cscourses]
excerpt_separator: <!--more-->
videos:
  - url: https://www.youtube.com/watch?v=k6U-i4gXkLM&list=PL4C4720A6F225E074&index=1
    title: Lecture 1 Dynamic Programming, Memoization, and Optimization
  - url: https://www.youtube.com/watch?v=Pij6J0HsYFA&list=PL4C4720A6F225E074&index=2
    title: Lecture 2 Introduction to Python Basics
  - url: https://www.youtube.com/watch?v=X6ilT3uUOBo&list=PL4C4720A6F225E074&index=3
    title: Lecture 3 Advanced Iteration and Programming Style
  - url: https://www.youtube.com/watch?v=SXR9CDof7qw&list=PL4C4720A6F225E074&index=4
    title: Lecture 4 Decomposition, Abstraction, and Recursion
  - url: https://www.youtube.com/watch?v=Pfo7r6bjSqI&list=PL4C4720A6F225E074&index=5
    title: Lecture 5 Python Numbers, Precision, and Approximations
  - url: https://www.youtube.com/watch?v=hVHqs38fPe8&list=PL4C4720A6F225E074&index=6
    title: Lecture 6 Bisection, Newton-Raphson, and Lists
  - url: https://www.youtube.com/watch?v=tuRYbBvOMRo&list=PL4C4720A6F225E074&index=7
    title: Lecture 7 List Aliasing, Dictionaries, and Efficiency Intro
  - url: https://www.youtube.com/watch?v=ewd7Lf2dr5Q&list=PL4C4720A6F225E074&index=8
    title: Lecture 8 Computational Complexity and Orders of Growth
  - url: https://www.youtube.com/watch?v=UNHQ7CRsEtU&list=PL4C4720A6F225E074&index=9
    title: Lecture 9 Binary Search, Sorting & Complexity
  - url: https://www.youtube.com/watch?v=kDhR4Zm53zc&list=PL4C4720A6F225E074&index=10
    title: Lecture 10 Divide and Conquer, Merge Sort, Hashing & Exceptions
  - url: https://www.youtube.com/watch?v=DkPsD58nUIE&list=PL4C4720A6F225E074&index=11
    title: Lecture 11 Validation, Debugging & The Scientific Method
  - url: https://www.youtube.com/watch?v=udnyuHzJsjM&list=PL4C4720A6F225E074&index=12
    title: Lecture 12 Debugging Strategies & Introduction to Optimization
  - url: https://www.youtube.com/watch?v=ZKBUu_ahSR4&list=PL4C4720A6F225E074&index=13
    title: Lecture 13 Dynamic Programming
  - url: https://www.youtube.com/watch?v=le8tpXQyYcM&list=PL4C4720A6F225E074&index=14
    title: Lecture 14 Pseudo-Polynomial Time, Problem Reduction
  - url: https://www.youtube.com/watch?v=y81AhLQN-NI&list=PL4C4720A6F225E074&index=15
    title: Lecture 15 OOP, Abstract Data Types, Encapsulation & Operator Overloading
  - url: https://www.youtube.com/watch?v=Q8SoG1OIveU&list=PL4C4720A6F225E074&index=16
    title: Lecture 16 Class Hierarchies & Inheritance and Collections & Iterators
  - url: https://www.youtube.com/watch?v=ZbIpjf0QEPI&list=PL4C4720A6F225E074&index=17
    title: Lecture 17 Computational Problem Solving & Random Walks
  - url: https://www.youtube.com/watch?v=QJ_MPc0TobI&list=PL4C4720A6F225E074&index=18
    title: Lecture 18 Simulation Structure, Debugging, and Pylab
  - url: https://www.youtube.com/watch?v=IZaAUwW7OsU&list=PL4C4720A6F225E074&index=19
    title: Lecture 19 Refactoring, Biased Walks, and Simulation Purpose
  - url: https://www.youtube.com/watch?v=ENrAsRoR97I&list=PL4C4720A6F225E074&index=20
    title: Lecture 20 Simulation Classification & Monte Carlo Methods
  - url: https://www.youtube.com/watch?v=SuOIpJnn888&list=PL4C4720A6F225E074&index=21
    title: Lecture 21 Monte Carlo Simulations, Linear Regression, and Over-Fitting
  - url: https://www.youtube.com/watch?v=WGDbIKtjmSs&list=PL4C4720A6F225E074&index=22
    title: Lecture 22 Distributions, Probability, and Statistical Pitfalls
  - url: https://www.youtube.com/watch?v=raTzkzML31w&list=PL4C4720A6F225E074&index=23
    title: Lecture 23 Statistical Sins, Stock Market Simulations, and Object-Oriented Design
  - url: https://www.youtube.com/watch?v=2q--tAPkVXI&list=PL4C4720A6F225E074&index=24
    title: Lecture 24 The Core Essence of Computer Science and Course Review
---

Welcome to **MIT 6.00: Introduction to Computer Science and Programming (Fall 2008)**—widely regarded as one of the most thorough and enduring foundational computer science courses ever recorded.

Taught by legendary MIT professors **Eric Grimson** and **John Guttag**, this course is specifically designed for beginners with little to no prior coding experience. Rather than just teaching syntax, 6.00 focuses on true **computational thinking**—teaching you how to conceptualize real-world problems and write elegant, efficient Python programs to solve them.

The 24-lecture syllabus takes you on a comprehensive arc from absolute beginner concepts to advanced modeling and statistical simulation:

---
<!--more-->


**📋 Quick Course Facts**

| Feature | Detail |
| --- | --- |
| **Institution** | Massachusetts Institute of Technology (MIT) |
| **Course Code** | 6.00 (Fall 2008) |
| **Instructors** | Prof. Eric Grimson & Prof. John Guttag |
| **Primary Language** | Python |
| **Prerequisites** | None (Beginner-friendly, though high school algebra is helpful) |

---
{% include video-series.html %}
---
**Table of Contents**
* TOC
{:toc}


---

### Lecture 1: Dynamic Programming, Memoization, and Optimization

* **Overlapping Sub-problems & Naive Recursion:** Demonstrates how standard recursive functions (like computing Fibonacci numbers) recalculate identical values across branches, causing execution times to grow exponentially.


* **Memoization:** Introduces storing previously computed results (e.g., in a dictionary) to turn exponential-time algorithms into linear-time ones.


* **Dynamic Programming Requirements:** Highlights that a problem must have *overlapping sub-problems* and *optimal substructure* to use this technique effectively.


* **0-1 Knapsack Problem:** Explores maximizing value under a weight constraint using a binary decision tree and shows how memoization drops millions of brute-force calls down to a fraction.



---

### Lecture 2: Introduction to Python Basics

* **Core Computational Goals:** Focuses on using programs, primitive data, and instructions to deduce new information.


* **Types, Expressions, and Operators:** Covers primitive types (numbers, strings, booleans), type conversion, operator overloading, and precedence rules.


* **Variables and Memory:** Explains that variables act as pointers or links to values in memory rather than storage boxes, utilizing dynamic typing.


* **Control Flow:** Details branching and conditionals (`if`, `elif`, `else`) alongside iteration (`while` loops) to modify execution flow.



---

### Lecture 3: Advanced Iteration and Programming Style

* **Programming Hygiene:** Emphasizes good style, including comments, descriptive variable names, type discipline, and defensive programming.


* **Iterative Constructs & Flowcharts:** Discusses loop mechanics, manual code simulation, and visual flowcharts to prevent infinite loops.


* **Collections and Loops:** Introduces exhaustive enumeration, `for` loops, strings, and immutable tuples.


* **Turing Completeness:** Concludes that the basic programming elements covered are sufficient to compute anything that can be described algorithmically.



---

### Lecture 4: Decomposition, Abstraction, and Recursion

* **Decomposition and Abstraction:** Explains how breaking code into manageable modules and hiding inner details ("black boxing") allows programmers to handle large codebases.


* **Functions:** Covers Python function syntax, the `return` keyword, docstrings, and the distinction between local and global variable scopes.


* **Problem-Solving & Brute-Force:** Demonstrates how functions handle enumeration and return multi-variable data via tuples.


* **Recursion:** Explores self-referential functions, breaking problems down using a clear **base case** and a **recursive step** (illustrated with palindrome checks and Fibonacci sequences).


### Lecture 5: Python Numbers, Precision, and Approximations

* **Integers & Floats:** Python supports arbitrary precision integers (`int`) that grow as needed, whereas floating-point numbers (`float`) use a 64-bit binary scientific notation (IEEE 754) capped at roughly 17 decimal digits of precision.


* **Inexact Representation:** Many fractions (like $$1/10$$) cannot be finitely represented in binary, resulting in small rounding errors that accumulate during iterative calculations.


* **Comparisons & Approximations:** Using `==` with floats is risky due to rounding approximations. Instead, use an absolute difference threshold ($$\epsilon$$).


* **Methods:** Computers use **successive approximation** and the **bisection method** to solve real-number problems, alongside defensive programming techniques like `assert` statements to validate inputs.



---

### Lecture 6: Bisection, Newton-Raphson, and Lists

* **Bisection & Regression Testing:** The bisection method narrows down solution intervals sequentially. Regression testing involves maintaining reusable test functions to verify code against known cases after edits.


* **Newton-Raphson Method:** An alternative root-finding approach using tangent lines and x-intercepts that converges much faster than bisection, though programmers must remain cautious of floating-point limitations.


* **Python Lists:** Lists are **mutable** (modifiable in place) and heterogeneous. Methods like `append()` add entire objects (creating lists of lists), concatenation (`+`) flattens lists by one level, and `remove()` deletes the first occurrence of a value.



---

### Lecture 7: List Aliasing, Dictionaries, and Efficiency Intro

* **Mutation & Aliasing:** Modifying lists in place changes the existing object. **Aliasing** occurs when two variables point to the same object in memory, meaning a change to one affects the other.


* **Dictionaries:** Mutable, unordered collections of key-value pairs that use **hashing** to achieve instantaneous **constant-time retrieval**.


* **Code Structure & Complexity:** Writing pseudo-code and using helper functions promotes modularity and separation of concerns. Time efficiency is evaluated analytically by counting **basic steps as a function of input size**, focusing on **worst-case analysis** to establish reliable upper bounds.



---

### Lecture 8: Computational Complexity and Orders of Growth

* **Asymptotic Notation (Big Oh):** Focuses on the rate of growth as input sizes increase, rendering additive and multiplicative constants insignificant. Big Oh describes the upper limit of an algorithm's growth.


* **Complexity Classes:**
* **Linear ($$O(n)$$):** Problem size reduces by a constant amount each step (e.g., iterative exponentiation, sequential search).


* **Logarithmic ($$O(\log n)$$):** Problem size is halved at each step (e.g., binary search).


* **Quadratic ($$O(n^2)$$):** Typically involves nested loops.


* **Exponential ($$O(2^n)$$):** Splits into multiple sub-problems, growing catastrophically fast (e.g., Towers of Hanoi).




* **Data Structures:** Accessing the $$i$$-th element of a list takes **constant time ($$O(1)$$)** under a random access model, unlike linked lists that require sequential traversal ($$O(n)$$).


---

### Lecture 9: Binary Search, Sorting & Complexity

* **Binary Search:** Operates on sorted lists by repeatedly halving the remaining search space, resulting in a logarithmic time complexity ($$\mathcal{O}(\log n)$$). It requires constant-time memory access, making it efficient for arrays but inefficient for linked lists.


* **Searching vs. Sorting Trade-offs:** While a single search is faster via linear search ($$\mathcal{O}(n)$$) than sorting first, performing multiple searches ($$k$$) on large lists makes sorting upfront ($$\mathcal{O}(n \log n)$$) and then using binary search much more efficient.


* **Basic Sorting Algorithms:** Covered **Selection Sort** (finding the smallest element and swapping it into place) and **Bubble Sort** (bubbling the largest element to the end through adjacent comparisons), both of which run in quadratic time ($$\mathcal{O}(n^2)$$).


* **Divide and Conquer:** Introduced as a strategy of breaking problems into smaller sub-problems, setting the stage for faster sorting algorithms like merge sort.



---

### Lecture 10: Divide and Conquer, Merge Sort, Hashing & Exceptions

* **Divide and Conquer Paradigm:** Follows a three-step process: **Divide** into sub-problems, **Conquer** them recursively to a base case, and **Combine** the solutions.


* **Merge Sort:** Recursively splits an unordered list down to singletons and merges them back in sorted order in $$\mathcal{O}(n \log n)$$ time.


* **Hashing:** Maps data into integers using a hash function to achieve constant time ($$\mathcal{O}(1)$$) lookups, trading space for time.


* **Python Exceptions & Asserts:** Differentiated between unhandled/handled exceptions (using `try`/`except` blocks and propagation) and debug-oriented `assert` statements used to check pre- and post-conditions.



---

### Lecture 11: Validation, Debugging & The Scientific Method

* **Validation vs. Debugging:** Validation is the continuous process of testing and reasoning to build confidence, whereas debugging identifies *why* a failing program behaves incorrectly.


* **Testing Classes:** Divided into **Unit Testing** (testing individual functions) and **Integration Testing** (testing the entire system).


* **Debugging Philosophy:** Emphasized that bugs are programmer errors (not mysterious entities) and that the best tools are careful code reading and `print` statements.


* **Systematic Debugging:** Outlined a scientific method approach—studying data, forming hypotheses, designing repeatable experiments, and utilizing a binary search (bisection) strategy to isolate errors.



---

### Lecture 12: Debugging Strategies & Introduction to Optimization

* **Debugging Best Practices:** Emphasized checking common mistakes (argument order, typos, aliasing), questioning assumptions, keeping written records of attempts, and taking breaks when stuck.


* **Optimization Problems:** Defined optimization as maximizing or minimizing a function subject to constraints. Examples include the Shortest Path, Traveling Salesperson, Bin Packing, Sequence Alignment, and Knapsack problems.


* **The Knapsack Problem:** Distinguished between the **Continuous Knapsack** (where a greedy algorithm works) and the **Zero-One (Discrete) Knapsack** (where greedy fails and brute-force exhaustive enumeration results in exponential time growth).


* **Introduction to Dynamic Programming:** Introduced as a way to solve exponential problems by leveraging overlapping sub-problems and optimal substructures, using the redundant computations of standard Fibonacci as a motivating example.



---


### Lecture 13: Dynamic Programming

* **Dynamic Programming Basics**: Explores how memoization cures the exponential time penalty of naive recursion (such as in Fibonacci calculations) by caching previously computed results.


* **Core Principles**: Highlights the two fundamental requirements for dynamic programming: **overlapping sub-problems** and **optimal substructure**.


* **0-1 Knapsack Problem**: Discusses how a brute-force decision tree ($$2^n$$ complexity) can be optimized using a memoized recursive approach (`max_val_fast`), drastically dropping required computations from millions down to thousands.



---

### Lecture 14: Pseudo-Polynomial Time, Problem Reduction

* **Pseudo-Polynomial Time & Trade-offs**: Explains that dynamic programming solutions run in pseudo-polynomial time (e.g., $$O(n \times s)$$), effectively trading memory space for execution time.


* **Problem Reduction**: Emphasizes evaluating whether a domain-specific challenge maps to a well-known canonical problem (like shortest paths) to leverage existing solutions.


* **Introduction to OOP**: Covers program organization through modules, encapsulation, and how classes define custom abstract data types.



---

### Lecture 15: OOP, Abstract Data Types, Encapsulation & Operator Overloading

* **Abstract Data Types (ADTs)**: Details how user-defined classes act as templates to bundle data and behavior together.


* **Core OOP Mechanics**: Explores class initialization via the `__init__` method, memory pointers (`self`), and the distinction between shallow (object) equality and deep (value) equality.


* **Encapsulation & Operator Overloading**: Emphasizes computational hygiene (data hiding via accessors) and demonstrates how special methods (like `__str__`) enable operator overloading and class composition.



---

### Lecture 16: Class Hierarchies & Inheritance and Collections & Iterators

* **Class Hierarchies & Inheritance**: Explains how subclasses inherit attributes and methods from superclasses, utilizing **shadowing/overriding** to specialize behavior.


* **Collections and Iterators**: Demonstrates how to make custom classes iterable by implementing special methods like `__iter__` and `__next__`.


* **Use Cases**: Notes that object-oriented programming is especially powerful for modeling complex systems composed of many interacting units (e.g., people or molecules).


### Lecture 17: Computational Problem Solving & Random Walks

* **Computational Strategies:** Focuses on shifting toward general techniques for solving hard computational problems, which involves building computational models, dealing with randomness (stochastic models), data visualization, and simulation evaluation.


* **The Random Walk Simulation:** Explores the "drunken student" scenario moving randomly in four directions to test whether expected distance grows over time (which simulation proves it does, counter to initial intuition).


* **Object-Oriented Design:** Utilizes Python class abstractions like `Location`, `CompassPoint`, `Field`, and `Drunk` to cleanly encapsulate movement rules and coordinates.


* **Programming Concepts:** Highlights default parameters, pseudo-randomness via the `random` module, and data plotting using Pylab.



---

### Lecture 18: Simulation Structure, Debugging, and Pylab

* **Method Syntax:** Emphasizes that omitting parentheses (e.g., `obj.method`) returns a method object rather than executing it, leading to silent bugs or type errors.


* **Simulation Structure:** Built using an inner loop for single trials, an outer loop for multiple trials, and statistical presentation via graphs.


* **Debugging & Graph Best Practices:** Suggests testing against simple known examples and checking math (like mean divisors). Recommends always labeling axes, providing a title, and calling `show()` for plots.


* **Applications & Tools:** Notes real-world uses of random walks (Brownian motion, stock markets, biology) and introduces Pylab/NumPy arrays for point-wise mathematical vector operations.



---

### Lecture 19: Refactoring, Biased Walks, and Simulation Purpose

* **Code Design & Polymorphism:** Structuring programs around classes isolates decisions, and using subclasses or passing class types as parameters allows code to handle multiple object variants cleanly.


* **Variants of Random Walks:** Explores biased walks (like "cold drunks" where a small bias makes a massive cumulative difference), East-West restricted walks, and spatial changes like "Chutes & Ladders" fields that slow progress.


* **Visualization & Distributions:** Recommends viewing data across multiple perspectives (paths, scatter plots, histograms), noting that unbiased walks typically follow a Normal (Gaussian) distribution.


* **Computer Simulations:** Originating during the Manhattan Project, simulations act as descriptive "experimental devices" when closed-form analytic solutions are impossible.



---

### Lecture 20: Simulation Classification & Monte Carlo Methods

* **Classification of Models:** Simulations are categorized by whether they are Stochastic vs. Deterministic, Static vs. Dynamic, and Discrete vs. Continuous.


* **Monte Carlo Simulations:** Coined by Ulam and Metropolis in 1949, these rely on inferential statistics where a random sample represents a broader population (e.g., observing how larger trial sizes stabilize coin-flip percentages).


* **Predicting vs. Estimating:** Simulations can forecast the future or estimate unknown current states, though builders must validate if past conditions reflect future ones.


* **Estimating $$\pi$$ via Randomization:** Uses dartboard methods (inscribing a circle in a square) to solve non-stochastic problems, demonstrating that simulations reach the correct neighborhood quickly but require substantial data for high precision.


---

### Lecture 21: Monte Carlo Simulations, Linear Regression, and Over-Fitting

* **Monte Carlo Simulations & Convergence:** High-volume simulations that yield consistent convergence show that your statistics are reproducible, but statistical validity does not automatically mean the model is correct. Results must always be cross-checked against physical reality.


* **Models and Least Squares:** Real-world data rarely matches theory due to error. Least squares objective functions are used to minimize squared differences, preventing positive and negative errors from canceling each other out.


* **Linear Regression & $$R^2$$:** Linear regression fits models based on linear *parameters*, allowing it to handle non-linear shapes like parabolas. The coefficient of determination ($$R^2$$) measures the proportion of response variation explained by the model, while unexplained variation can stem from experimental error or lurking variables.


* **The Danger of Over-Fitting:** Using overly complex higher-order polynomials yields a tighter fit to initial data but fails at extrapolation because it captures random noise rather than true trends.



---

### Lecture 22: Distributions, Probability, and Statistical Pitfalls

* **Probability Distributions:** Covers the Normal (Gaussian) distribution (described by mean and standard deviation, following the empirical rule where ~68% of data falls within 1 standard deviation and ~95% within 2), the Uniform distribution, and the Exponential distribution (commonly used for arrival times).


* **Simulating Games of Chance:** Simple code simulations make it easy to analyze complex probabilities and test "what-if" scenarios (like biased dice) without manual math.


* **Statistical Sins & Pitfalls:** Highlights common misuses of data, including relying on summary statistics without seeing raw data, assuming correlation implies causation (often driven by lurking variables like socioeconomic status), non-response bias (unrepresentative samples), and presenting data out of context.



---

### Lecture 23: Statistical Sins, Stock Market Simulations, and Object-Oriented Design

* **Statistical Fallacies:** Reviews data extrapolation errors and the "Texas Sharpshooter Fallacy"—the mistake of finding random patterns or clustering after the fact and drawing conclusions around them.


* **Stock Market Simulation:** Introduces a simulation comparing indexed vs. managed portfolios against foundational economic models like the Efficient Market Hypothesis (EMH) and momentum investing perspectives.


* **Python & Implementation Details:** Uses object-oriented design (hierarchies like `Stock` and `Market`), lambda functions to assign randomized volatility distributions, and multiplicative modeling for stock prices since price movements scale proportionally to current value.



---

### Lecture 24: The Core Essence of Computer Science and Course Review

* **Computational Thinking:** Frames computational thinking as an experimental discipline involving abstractions, computational experiments, efficient implementation, and rigorous validation. Code acts as an "acid test of truth" that exposes flawed work instantly.


* **Real-World Applications:** Highlights the application of machine learning, algorithms, and signal processing to medicine, such as detecting early seizure onsets for epilepsy and predicting cardiac events.


* **Course Accomplishments:** Recaps the term's major focus areas: Python notation, systematic testing and debugging, problem formulation and reduction, algorithm design (greedy, divide and conquer, dynamic programming, big-O), and stochastic simulations.


* **Next Steps:** Suggests follow-up pathways such as courses in robotics, artificial intelligence, software engineering, and algorithms.

