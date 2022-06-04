
### Fast, flexible, phonetic and keyboard match, full-text search in sql server with zero dependencies.


# Searloc
**Sear**ch **loc**al in your sqlserver database, with a text pattern, like searchings you do on internet via search engines (google, duckduckgo, etc). 
It Supports:


* **Full text searching**.
    
    You can search in texts, sentences, full names (first names, last names), etc. just with typing one-two words or prefixes, etc. 
 
* **Phonetic match in all languages**.  
    > e.g. 
    > * word **'Accelarate'** can be matched with pattent **'axelarate'** ('cc' and 'x'  pronounced the same)
    > * word **'helloween'** can be matched with pattern **'helowin'** (match 'll' with 'l' and 'ee' with 'i')  
    > * greek word **'παίζω'** can be mathced with **'πέζο'** or **'pezo'** 
    > * german word **'Entschuldigung'** can be matched with **'Entsuldigung'** ('s' and 'sch' pronounced the same)
    > * arabic word **'مرحبا'** can be matched with 'MRHB' 

* **Flexible - fuzzy searching.**. 

    Can match words and patterns when some letters are missing. This is for the case user types something quickly and pass-by some letters)  
    > e.g. word **'manufacturer'** 
    > can be matched with pattern **'mnfacturer'** 
    > although letters 'a' and 'u' are missing.
 
* **Keyboard matching**. 

    It is very common to type a word to search and  forget to change language in keyboard. This library can match also these without problem. 
    > e.g.
    > greek word **'ΨΑΘΑ'** can be matched with **'CAUA'** 
    > because if you want to type letter 'Ψ' in greek keyboard you press 'C', 
    > and for letter 'Θ' you press 'U' 
 
* **Prefix matching.** 
    
    You can give as patterns all the letters (one by one) that user types for searching. 
    > e.g. word **'true'** can be matched with 
    > **'t'** or 
    > **'tr'** or 
    > **'tru'** or 
    > **'true'**   
 
* **Code - number searching**.

    You can search codes, phone numbers, etc 
 
* **Symbol searching**.

    When creating indexes for searching, this mechanism ignores some symbols (commas, dots, brackets, etc), but  in some cases it keeps them.<br>
    > e.g. for text   **Question A.1. What are functions (examples);  f(x) and f(y) are called "functions"**<br>
    > will be created indexes for words: 
'question',  'A.1', 'what', 'are', 'functions', 'examples', 'f(x)', 'f(y)', 'called',  'functions'. 
    > **(Notice that in A.1 dot is kept, and in f(x) and f(y) parenthesis are not removed)**   

* **Fast searching**. 
    
    You can easily search millions of records, in milliseconds!!!

* **Search per table.**. 

    You can create indexes for each table, declaring one or more columns to search, and the priority of columns while searching. 

* **Small footprint** 

    Library size is only 180KB

## Where to use this library

Anywhere you need flexible and fast text searching in your sqlserver database, you can use it.

For example if you have an site with e-shop, you propably want when the user types something, to search fast and flexible in all product names, descriptions, codes etc, to show him a small list with products that matches better with the text he typed.

Or you have an application with a customer table and you want searchings in last names, first names, phones, emails, etc.

Or you have a table with documents with many words in each record, and you want fast searching in all of them to find the most suitable sentense.

## Dependencies.
No dependencies. No need to install sqlserver's full-text search, it has its own mechanism

## Documentation
see [SEARLOC.md](/SEARLOC.md)  

## Installation - Example 
There is a folder [SQL](/SQL) which contains some sql commands to run for install, with demos and tests.
* Create a new Database or use an existing. 
	> If you choose to use an existing database, this must be less than 5GB, to avoid errors in LIMITATION MODE. See [license](#License)
	
* Install searloc. 

	>Execute file [install.sql](/SQL/install.sql) to create the installation procedure 
	and after run	`` EXEC dbo.searloc_install ``

* Load and run file [1. create demo table.sql](/SQL/1.-create-demo-table.sql) 

	> This will create a demo table with all internation codes of diseases (ICD10). Its only for demo use.
	
* Load and run file [2. search with function.sql](/SQL/2.-search-with-function.sql)	

	> This will create an auxilary function and make some test searchings, scanning whole table. You will notice the speed of searching is fast enough, although the table contains about 10K records. 
	
* Load and run file [3. search with index.sql](/SQL/3.-search-with-index.sql)	

	> This will create a **searloc index** for this table, and make the same searchings as previous example. You will notice the speed will be very - very fast. If the table had millions of records speed will be also very good (just a few milliseconds in most cases)


## Release History
see [RELEASE HISTORY.md](/RELEASE_HISTORY.md)  
 

## How it works. (A brief explanation)
All data handled by this library are stored in separate schema named **[searloc]**.
By creating an index in a table, automatically creates 2 shadow tables in this schema and 3 triggers (for insert, for update, for delete) in the source table.
  > e.g. <br>
  > if you create index for table **[dbo].[products]**, automatically will be created
  > * table **[searloc].[products_1]** 
  > * table **[searloc].[products_2]**
  > * trigger **[tr_searloc_auto_products_ins]** for table **[dbo].[products]**
  > * trigger **[tr_searloc_auto_products_upd]** for table **[dbo].[products]**
  > * trigger **[tr_searloc_auto_products_del]** for table **[dbo].[products]**
  >..

In the moment you create indexes, they will be updated with the present records of the table, and this will take some time (in my laptop for 1 million records, it took about 150 seconds). After this for any insert, update, delete in source table triggers will be fired and automatically updates shadow tables. 

> Normally these shadow tables requires space in database file about 3 times of the space needed by source data.

When you make searchings, mechanism reads only from shadow tables, to find records with best scores, and returns ids of source table. It uses something like radix tree algorithm to make fast searchings, but with many patents to reach the desired results and desired time. All these patents are mine, I created them after hard work, many tests, and too many attempts.

Library includes a very big dataset with all phonetic matchings, and keyboard matchings for each unicode character or set of characters. I excluded only Chinese Japanese and Korean phonetic matching, to keep libaray in small size. 


## License

    Searloc library
    Copyright (C) 2022 Dimitris Tsimpoukelis 

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <https://www.gnu.org/licenses/>.



**This library is free to use it anywhere. But it has the limitation mdf file of your database to be smaller than 5GB**.<br>

For bigger database files you need to register your company name and a key for it.
Please contact to email [dim1.tsimpoukelis@gmail.com](mailto:dim1.tsimpoukelis@gmail.com) if you want to obtain a key for your company, for a lifetime and for unlimited installations. 

 

