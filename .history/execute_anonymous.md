2016-05-15 10:55:07
```java
Set<String> strSet = new Set<String> {'a', 'b', 'c', 'd'};
System.debug(LoggingLevel.INFO, '*** strSet.retainAll('a'): ' + strSet.retainAll('a'));
```

2016-05-15 10:55:23
```java
Set<String> strSet = new Set<String> {'a', 'b', 'c', 'd'};
System.debug(LoggingLevel.INFO, '*** strSet.retainAll( ' + strSet.retainAll('a'));
```

2016-05-15 10:55:38
```java
Set<String> strSet = new Set<String> {'a', 'b', 'c', 'd'};
System.debug(LoggingLevel.INFO, '*** strSet.retainAll( ' + strSet.retainAll('a'));
```

2016-05-15 10:55:48
```java
Set<String> strSet = new Set<String> {'a', 'b', 'c', 'd'};
System.debug(LoggingLevel.INFO, '*** strSet.retainAll( ' + strSet.retainsAll('a'));
```

2016-05-15 10:56:15
```java
Set<String> strSet = new Set<String> {'a', 'b', 'c', 'd'};
strSet = strSet.retainAll('a');
System.debug(LoggingLevel.INFO, '*** strSet.retainAll( ' + strSet);
```

2016-05-15 10:56:25
```java
Set<String> strSet = new Set<String> {'a', 'b', 'c', 'd'};
strSet = strSet.retainsAll('a');
System.debug(LoggingLevel.INFO, '*** strSet.retainAll( ' + strSet);
```

