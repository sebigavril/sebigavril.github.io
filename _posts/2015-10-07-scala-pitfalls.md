---
layout: post
title: Scala pitfalls
category: coding
tags: scala, pitfalls  
year: 2015
month: 10
day: 7
published: true
summary: Bits of tricky Scala code  
image: 2015-10-07.png
---

### Intro


I have gathered these code snippets while my team and I were learning Scala for a new project. The following examples are meant to illustrate some of Scala's oddities that you might encounter while programming. The version of Scala used is 2.11.7. 

------

{% assign i=0 %}

{% assign i=i | plus:1 %}   
#### Snippet {{i}}
So what does line 6 print?
{% highlight scala linenos %}
class Foo {
  println(x)
  val x = 1
}

new Foo
{% endhighlight %}

{% hide <b>See answer</b> %}
Result
     
    0

This is a simple one... The code prints `0` because `x` is not yet initialized when the call to `println` is made.
{% endhide %}

------

{% assign i=i | plus:1 %}   
#### Snippet {{i}}
Obviously, line 6 will now print `1` because `x` is now properly initialized. But what does line 7 print? 
{% highlight scala linenos %}
trait Foo { 
	val x = 1
	println(x) 
} 

new Foo {} 
new Foo { override val x = 2 } 
{% endhighlight %}

{% hide <b>See answer</b> %}
Result

    0

This is because we're overriding `x` and at the time `println` is being called `x` is not yet initialized.  
{% endhide %}

------

{% assign i=i | plus:1 %}   
#### Snippet {{i}}
What gets printed by this snippet?
{% highlight scala linenos %}
val p = Seq(1,2,3).permutations
if (p.size < 10) {
	println("Permutations:")
  	p foreach println 
  	println("Done")
}
{% endhighlight %}

{% hide <b>See answer</b> %}
Result

    Permutations:
    Done

The reason for this is that calling `permutations` returns a cheap object called an `Iterator` that does not yet contain the permutations we're interested in. Calling `size` on the iterator will consume it entirely, as it computes all the permutations to get the total number. Thus, line 4 will end up with an empty iterator.  
{% endhide %}

------

{% assign i=i | plus:1 %}   
#### Snippet {{i}}
How about lines 4 and 5?
{% highlight scala linenos %}
List(1, 2, 3).map { i => i + 1}   // List(2, 3, 4)
List(1, 2, 3).map { _ + 1 }       // List(2, 3, 4)

List(1, 2, 3).map { i => println("Hi"); i + 1 }
println
List(1, 2, 3).map { println("Hi"); _ + 1 }
{% endhighlight %}

{% hide <b>See answer</b> %}
Result

    Hi
    Hi
    Hi
    List(2, 3, 4)

    Hi
    List(2, 3, 4)

This is because the print statement is not part of the map function that is being applied over and over again for every element in the list. Rather, it is only evaluated once, hence the single `Hi` message. 
{% endhide %}

------

{% assign i=i | plus:1 %}   
#### Snippet {{i}}
What would applying this function to the following Set return?
{% highlight scala linenos %}
import scala.collection.Set

def f: Int => Int = x => x % 3

Set(3, 6, 9).map(f)  
{% endhighlight %}

{% hide <b>See answer</b> %}
Result
    
    Set(0)

The function returns `0` for all of the 3 elements of the Set. And because Sets don't allow duplicates, we're left with a one element Set. 
{% endhide %}

------

{% assign i=i | plus:1 %}   
#### Snippet {{i}}
This is a tricky one and is very Scala specific...  
{% highlight scala linenos %}
List(1, 2, 3).toSet()
{% endhighlight %}

{% hide <b>See answer</b> %}
Result

    false

Confused? Well, it turns out that Scala is happy enough to insert a `Unit`, if it thinks that's what you want. The thing is that `toSet` is a side effect free function that does not have any parameters, hence no parentheses. When you call `.toSet()` Scala thinks that you want to call the `apply` method on the newly created Set. But apply it with what? Well, with the `Unit` we just said that Scala is nice enough to insert for you. And of course, the Set does not contain an `Unit`, so it returns false. 
{% endhide %}

------

{% assign i=i | plus:1 %}   
#### Snippet {{i}}
Will this pass the compiler?
{% highlight scala linenos %}
List(1, 2, 3) contains "the reader of this article"
{% endhighlight %}

{% hide <b>See answer</b> %}
Result
  
    false

Yeah, the language that is so "typesafe" will not throw a compiler error in this case.
{% endhide %}
------

{% assign i=i | plus:1 %}   
#### Snippet {{i}}
Creating a string from a parallel collection... What would that string look like? 
{% highlight scala linenos %}
Set(1,2,3,4,5).par mkString(" ")
{% endhighlight %}

{% hide <b>See answer</b> %}
Result
  
    5 1 2 3 4

One would expect the result to vary since we're using a parallel collection. Try as much as you would like, but this will always return `5 1 2 3 4`.
{% endhide %}

------

{% assign i=i | plus:1 %}   
#### Snippet {{i}}
Doing pattern matching on generics...
{% highlight scala linenos %}
Seq("1", "2", "3") match {
  case _ : List[Int] => println("List of Ints")
  case _ : List[String] => println("List of Strings")
  case _ => println("Something else")
}
{% endhighlight %}

{% hide <b>See answer</b> %}
Result
  
    List of Ints

You shouldn't match on generic types because of type erasure. If you do, Scala will happily just match the first line that matches the type you applied generics on.  
{% endhide %}

------

{% assign i=i | plus:1 %}   
#### Snippet {{i}}
This is just an example of applying the same map operation in 2 ways. What will the output be?
{% highlight scala linenos %}
import scala.collection.BitSet

BitSet(1, 2, 3) map (_.toString.toInt)
BitSet(1, 2, 3) map (_.toString) map (_.toInt)
{% endhighlight %}

{% hide <b>See answer</b> %}
Result

    BitSet(1, 2, 3)
    TreeSet(1, 2, 3)

...although `map(f(g))` should be identical to `map(f).map(g)`    
{% endhide %}

------

{% assign i=i | plus:1 %}   
#### Snippet {{i}}
What will get printed at line 6 and 7?
{% highlight scala linenos %}
class C

val x1,x2 = new C
val y1@y2 = new C

println(x1 == x2)
println(y1 == y2)
{% endhighlight %}

{% hide <b>See answer</b> %}
Result

    false
    true

Line 3 is a sequence of definitions. So each variable on the line gets its own instance of class `C`. On the other hand, line 4 is a pattern binder that binds `y1` of type `y2` (which in this case is a variable pattern matching anything and binding `y2` to it) to an instance of class `C`. This means that both `y1` and `y2` are bound to the same instance.  
{% endhide %}
------

{% assign i=i | plus:1 %}   
#### Snippet {{i}}
How about calling methods on uninitialized strings?
{% highlight scala linenos %}
val s1: String = s1
val s2: String = s2 + s2
println(s1.length)
println(s2.length)
{% endhighlight %}

{% hide <b>See answer</b> %}
Result

    java.lang.NullPointerException
      at ...
    8

Obviously, `s1` is `null` and calling any method on a null object will throw a NPE. But the interesting thing is that `s2` is not `null`, but `nullnull` which gets treated as a string. 
{% endhide %}

------

#### References

* [https://github.com/scala/scala.github.com/blob/pitfalls/overviews/core/_posts/2014-04-08-language-pitfalls.md](https://github.com/scala/scala.github.com/blob/pitfalls/overviews/core/_posts/2014-04-08-language-pitfalls.md)
* [http://scalapuzzlers.com](http://scalapuzzlers.com)
* [https://www.youtube.com/watch?v=uiJycy6dFSQ](https://www.youtube.com/watch?v=uiJycy6dFSQ)
* [http://beust.com/weblog/category/scala](http://beust.com/weblog/category/scala)
