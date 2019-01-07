# citynames-clustering

When you type *whether in paris* in your browser it's quite obvious for everybody that you are actually asking for the "weather" not "whether". Indeed, the browser will immediately provide some search suggestions matching the word "weather" directly. But How does it knows? How did it decide that your query was wrong in the first place and corrected it? Such techniques involve computations known as "string distance". Indeed, two strings can be compared based on the number of common characters, the number of matching sub-sequences of N consecutives characters, or the number of edit operations needed to switch from one to the other. Dozens of related or combined metrics, more or less complicated, exist.

![search](search_suggestion.png)

This project will try to use these tools to compare the names of the 35921 cities in France, some being as long as "SAINT MARTIN DE BIENFAITE LA CRESSONNIERE", others as short as 1 character (one is named just "Y" https://fr.wikipedia.org/wiki/Y_(Somme) ). Clearly, those two will be hard to compare, right?

![Y](y_city.png)

Once we have a metric (ideally between 0 and 1) to compare two random city names, we can do two fun things:
- plot all cities with a high matching score to any given city, on a map
- build a classification that will (hopefully) bring out meaningful clusters of cities with close names ("DIEFFENBACH AU VAL" and "DIEFFENBACH LES WOERTH") and tell us about French History... 

Actually, building knowledge out of city names is a rather classic geographical science (it's called toponymy), and already has a dense litterature, though I couldn't find any use of statistical clustering on this kind of data. Those of you who aren't data scientist might be feel a little bit like John in the following almose-real geeky movie dialog (and are therefore allowed to skip some sections) :

*"Robert, please tell me you have located the murderer?!"* / 
*"Well John, I got something but I had to relocate the satellite and run a 128bit decryption algorithm, then I checked the modified DNA database but I..."* / 
*"For God's sake Robert, what did you find?"*

All right, you got my point. Let's do some more Robert here. 

## 1. How do we get the cities database?

All cities and villages with GPS locations in France are available at the [data gouv platform](https://www.data.gouv.fr/fr/datasets/listes-des-communes-geolocalisees-par-regions-departements-circonscriptions-nd/); however after having repeatedly treated such data for electoral analysis, I was well aware of the poor data quality and how it was a real pain to clean those names for special characters, duplicates, missing GPS locations etc. In the discussion forum someone already had a cleaned dataset merged with data from LA POSTE (see the post [here](https://www.datavis.fr/index.php?page=validate-your-data)), with very name in upper case, no special character, 100% geolocated, just what I needed.
We also imported a simplified geoshapeData file to get an emtpy map of France and its departments from [here](https://www.data.gouv.fr/fr/datasets/contours-des-departements-francais-issus-d-openstreetmap/).

## 2. How do we pretreat the data?

For your specific use the data even has to be a bit transformed. The city names have a lot of stuff that seemed useless to compute proximities between two names, like prepositions LE, EN, SUR, DE, etc. Indeed, AIRE-SUR-L'ADOUR and AIRE-SUR-LA-LYS are 1000km far from each other, have nothing in common except those "stop words" constructs and would wrongly appear in the same cluster if we didn't remove them. By doing so, we change their semantic proximity from 0.57 to 0.72. Same goes from all the religious names having SAINT/SAINTE(S) in the name; but I had first to check if the geographical repartition of those religious names was random, and it seemed to be the case.
To achieve these operations, I use a chunk of code like this:

`gsub(" D[EU]?S? | L[EA]?S? | SAINTE? | SUR | AUX? | EN | ET | SOUS ", " ", com$nom)`

We decided to keep the spaces and not collapse the components of the city names, because spaces are important. Some things we decided to keep, such as "notre dame", "lez", "pres", "es", because we thought they might bring some relevant historical information. So, remember that very long city name? Now it's become "MARTIN BIENFAITE CRESSONNIERE"

## 3. Distance metrics

The hard part is to find the right string distance metric to describe the similarity between two city names. Most metrics are designed to deal with text misspell problems or variations, such as "GOOGLE" and "GOOGEL", and often cannot handle properly strings of very different lengths. What we would like to capture is mainly:
- groups of letters, representing common historical origin like "SAINT REMY D'URFE" and "SAINT MARCEL D'URFE"
- small changes in letters, accounting for progressive transformation of the names through time, like: "BUSSIERE SAINT GEORGES" and "BUSSIERE**S** ET PRUNS" (see the S)

The first would be represented by an q-gram component of degree 3 or 4: "ARDILLERES" and "ARDILLEUX" have three 4-grams in common being ARDI, RDIL, and DILL. Their jaccard distance is : 1-3/11=0.7272. The second distance, called Levenshtein distance, computes the number of single-character changes to go grom one to the other, and needs to be normalized for the length of the string. We can build a weighted combination of those two indices. Let's check an example with the city of *"MONTIGNY (SUR) LOING"*

The first method gives for instance proximities with : **"MONTIGNY", "MONTIGNY AIN", "MONTIGNY MONTS", "MONTIGNY LENCOUP", "MONTIGNY METZ", "MONTIGNY AVRE", "MONTIGNY AUBE", "MONTIGNY LENGRAIN"**, you see that it tends to keep the chunks

The second method yields **"MONTIGNY AIN", "MONTIGNY MONTS", "FONTENAY LOING", "MONTIGNY ALLIER"**, but also stuff like **"MONTAGNY VEXIN", "ORBIGNY MONT", "MONTIGNAC COQ"**, accounting for small variations that might sometimes be irrelevant or too destructive, of course.

We could even think of adding some geographical weighting in the similarity, to favour grouping of cities that are not too far away from each other.

## 4. Check it out on the map!

If you want to play with some cities similarities and see what it returns on a map of France, you can check out my [**little application HERE**](shiny link missing)





