---
layout: post
title: Scala's call-by-name and Mockito's spying
category: coding
tags: scala, mockito, call-by-name, testing  
year: 2015
month: 10
day: 14
published: true
summary: How to spy a method that is being called with call-by-name parameters, using Mockito
image: 2015-10-14.png
---

### Intro

Scala has a neat feature called [call-by-name](http://twitter.github.io/effectivescala/#Functional programming-Call by name). Basically, you can call a method in 2 ways:

 * call-by-value (the default)
 * call-by-name

When you do a call-by-value, the method parameters are instantiated and passed as values (well, references to those values to be more precise). On the other hand, when you do a call-by-name, the parameters are not instantiated when the method is invoked, but when/if they are actually used inside that method. 

Take for example logging: `eventLogger.info(new Event())`. We're logging generic events, not just strings. Eventually, most of them end up in a classic logging framework, but others are piped to other destinations, such as [Kafka](http://kafka.apache.org/). Some of these events are costly to build. So if the log level is set to `DEBUG` for example, it makes no sense to instantiate `Event` because we're sure it will be ignored. However, the default behavior is to instantiate it. To change this, we change the method signature from `def info(event: Event)` to `def info(event: => Event)`. This is it. This is a call-by-name. The `Event` class will only be instantiated if it is actually needed by the method.

### Spying with Mockito

Now let's test this. Testing the call-by-value approach would look like this:

{% highlight scala linenos %}
"EventLogger" should {
  "log an event with no exception" in {
      val eventLogger = spy(new EventLogger())
      Await.result(eventLogger.info(simpleEvent), 5 seconds)
      there was one(eventLogger).log(simpleEvent, Level.INFO)
    }
}
{% endhighlight %}

We're just testing that when calling `.info`, an inner method called `log` is called with the correct parameters: the event to log and the log level set to `INFO`. 

But if we change the method to use call-by-name, the test fails. Line 5 will fail because the expected `Event` argument does not match the one it receives. To make it work, we have to do a couple of changes:

{% highlight scala linenos %}
private def callByNameEvent(event: Event) =
  new (() => Event) {
    def apply() = event
    override def equals(o: Any): Boolean =
      event == o.asInstanceOf[() => Event].apply()
  }

"EventLogger" should {
  "log an event with no exception" in {
      val eventLogger = spy(new EventLogger())
      Await.result(eventLogger.info(simpleEvent), 5 seconds)
      there was one(eventLogger).log(callByNameEvent(event).apply(), Level.INFO)
    }
}
{% endhighlight %}

It took me a while to make this work. Hopefully, it will save someone some time.