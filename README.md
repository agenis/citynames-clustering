# citynames-clustering

When you type "wether in paris" in your browser it's quite obvious for everybody that you are actually asking the the "weather" not "whether". Indeed, the browser will immediately provide some search suggestions mathing the word "weather" directly. But How does it knows? How did it decide that your query was wrong and auto-corrected it? These operations involve techniques known as "string distance" computations. Two strings can be compared based on the number of common characters, the number of matching sub-sequences of N consecutives characters, or the number of edit operations needed to switch from one to the other.

This project will try to use these tools to compare the names of the 36000 or so cities in France, some being as long as "SAINT MARTIN DE BIENFAITE LA CRESSONNIERE", others as short as 1 character (it's named just "Y" https://fr.wikipedia.org/wiki/Y_(Somme) ). Clearly, those two will be hard to compare, right?

Once we have a metric to compare two random city names, we can do two fun things:
- plot all cities with a high matching score to a chosen one, on a map
- build a classification that will (hopefully) bring out meaningful clusters of cities with close names ("DIEFFENBACH AU VAL" and "DIEFFENBACH LES WOERTH") and tell us about French History... 

Actually, emerging knowledge out of city names is a rather classic scientific domain, called toponymy, and already has a dense litterature. IThough, I couldn't find any use of statistical clustering on this kind of data.




