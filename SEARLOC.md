# HOW TO INSTALL searloc
 Execute file [install.sql](/SQL/install.sql) to create the installation procedure 
	and after run

`` 
EXEC dbo.searloc_install 
``

>This pocedure installs or re-installs library. In case you want to unistall, and delete all data used by this library you can call ``searloc.drop_all``

# CLR procedures - functions (alphabetical order)

* [PROCEDURE **searloc.create_index**](#user-content-procedure-searloccreate_index)
* [PROCEDURE **searloc.drop_all**](#user-content-procedure-searlocdrop_all)
* [PROCEDURE **searloc.drop_index**](#user-content-procedure-searlocdrop_index)
* [FUNCTION **searloc.match**](#user-content-function-searlocmatch)
* [FUNCTION **searloc.match_selection**](#user-content-function-searlocmatch_selection)
* [TABLE FUNCTION **searloc.search**](#user-content-table-function-searlocsearch)
* [FUNCTION **searloc.suggest**](#user-content-function-searlocsuggest)



# PROCEDURE searloc.create_index
`` EXEC searloc.create_index @TableName, @Fields1, @Fields2, @Fields3, @Action ``

Creates a searloc index for a specific table and fields. You can create only one searloc index per table.

Parameters:
- **@TableName NVARCHAR(MAX)**  

    Name of source table (e.g. 'products'  or 'dbo.products'). The table must contain one primary key field type of BIGINT or INT or SMALLINT or TINYINT
    
- **@Fields1 NVARCHAR(MAX)** 

    Set of names of source columns of the table, separated by ','
    
- **@Fields2 NVARCHAR(MAX)** 

    Set of names of source columns of the table, separated by ',' or NULL. @Fields2 will have lower priority in search, comparing with @Fields1
    
- **@Fields3 NVARCHAR(MAX)** 

    Set of names of source columns of the table, separated by ',' or NULL. @Fields3 will have lowest priority in search of all others
    
- **@Action NVARCHAR(MAX)** 

    Declares what to do when index of the table already exists:
    * **Action = NULL** -> if index already exists raise error.
    * **Action = 'rebuild'** -> if index already exists rebuild index (drop previous and create new one).
    * **Action = 'no action'** -> if index already exists do nothing.
    * **Action = 'drop'** -> if index already exists drop index (same as searloc.drop_index).
     
e.g.
`` EXEC searloc.create_index 'customers', 'Code, LastName, FirstName', 'City', NULL, 'rebuild' ``
     
     
After you create searloc index for a table automatically 3 triggers will be created in source table (started from [tr_searloc_auto_]) one for insert, one for update, and one for delete.
Any changes you will make on source table automatically will update searloc indexes too.
The space that uses this library for an index is about 3 times the space source data uses.

Finally after you create index for a table, you can use function ``searloc.search`` to make fast searchings in this table.

If you want in the future to drop the index you can use ``EXEC searloc.drop_index``




# PROCEDURE searloc.drop_all
`` EXEC searloc.drop_all ``

Will drop

- All auxiliary tables - indexes in schema **searloc**, which created by this library
- All triggers in source tables created by this library (started with **tr_searloc_auto_**)
- All CLR functions, procedures and assembly of this library
- Will drop schema **searloc**

After calling this procedures, database will be free of all data used by this library.
If you want to use library again you have to install it, and create index(es) again.





# PROCEDURE searloc.drop_index
`` EXEC searloc.drop_index @TableName ``

Drops (if exists) a searloc index. If index not exists just returns without error

Parameters:
- **@TableName NVARCHAR(MAX)**  

    Name of source table.

After you drop index, will automatically drop the triggers in source table related to this.



# FUNCTION searloc.match 
`` SELECT searloc.match(@Pattern, @Text) ``

It will try to match pattern words with the text words and returns a score  

Parameters:
- **@Pattern NVARCHAR(MAX)** 

    The pattern text
    
- **@Text NVARCHAR(MAX)** 

    The text that will be searched

Returns
**INT** the score (max. score=1000)

Examples
-  `` SELECT searloc.match('ex', 'Hello this is an example') `` will return 1000
as prefix 'ex' exists in begining of word 'example'
- `` SELECT searloc.match('FANT OPRA', 'Phantom of the Opera')`` will return 893
as prefix 'FANT' can be matched with 'Phantom' and OPRA with 'Opera'
-  `` SELECT searloc.match(N'elinika', N'ΕΛΛΗΝΙΚΑ') `` will return 950
as there is a phonetic match

You can use this function to scan whole table and return the top records with best scores

e.g.
```
DECLARE @P NVARCHAR(MAX) = 'john alb'
SELECT TOP 6 
  id, 
  searloc.match_selection(@P, ISNULL(LastName, '') + ' ' + ISNULL(firstName, ''), '<b>', '</b>') ,
  searloc.match(@P, ISNULL(LastName, '') + ' ' + ISNULL(firstName, '') ) 
FROM Customers
WHERE searloc.match(@P, ISNULL(LastName, '') + ' ' + ISNULL(firstName, '') ) >= 750
ORDER BY 3 DESC
```

Of course if your table is big with many thousants, or millions records then you have to 
``create_index`` for this table and use ``searloc.search`` for faster searchings.  
 
 
 
 
 
# FUNCTION searloc.match_selection 
`` SELECT searloc.match_selection(@Pattern, @Text, @SelectionBegin, @SelectionEnd) ``

It will try to match pattern words with the Text words (as function ``searloc.match``) and returns the original text with selections of matches  

Parameters:
- **@Pattern NVARCHAR(MAX)** 

    The pattern text
    
- **@Text NVARCHAR(MAX)** 

    The text that will be searched
    
- **@SelectionBegin NVARCHAR(MAX)** 

    The text than will be inserted in selection begin
    
- **@SelectionEnd NVARCHAR(MAX)** 

    The text than will be inserted in selection end


Returns
**NVARCHAR(MAX)** text with selections of match

Examples
-  `` SELECT searloc.match_selection('ex', 'Hello this is an example', '<b>', '</b>') `` <br> will return `` 'Hello this is an <b>ex</b>ample' `` 
- `` SELECT searloc.match_selection('FANT OPRA', 'Phantom of the Opera', '<b>', '</b>') ``
<br> will return ``<b>Phantom</b> of the <b>Opera</b>`` 
<br>(It will select all word 'Phantom' here because it cannot match exactly the pattern 'FANT')


 
# TABLE FUNCTION searloc.search
`` SELECT * FROM searloc.search(@TableName, @SearchText, @Limit, @UserID)``

It will search fast whole table and returns records with best matches. 
The table you scan, must have been indexed with ``searloc.create_index`` 

Parameters:
- **@TableName NVARCHAR(MAX)** 

    The name of the table (e.g. 'products'  or 'dbo.products').
    In case you want to search in a part only of a table you can use syntax **'table_name # where_clause'**. 
    In the where_clause you can use **w0.id** to join the record
    >e.g. 'Customers# ISNULL((SELECT cancelled FROM Customers WHERE id=w0.id), 0)=0'
    
- **@SearchText NVARCHAR(MAX)** 

    The text that you want to search. Can be one or more whole words or prefixes. e.g. 'John K' will search for all words started or matched with 'John' and 'K' 
    
- **@Limit INT** 

    is the number of top records that will return. If it is NULL or zero will return all records with matches, but this may cause big delay. A good practice is to set a number equal or below 10. 
- **@UserID BIGINT** 
    
    It is optional (can be NULL). Is you set UserID this function will keep in memory history of last searches of the user, and will give him best experienced results. The history that kept for its user is temporarily stored in memory and after a short time may be released.  

Returns table with columns
- **id BIGINT**  id of record in source table
- **score INT** score of the matching (max=1000)
 
 e.g. 1
 ```
 SELECT
    s.id, (SELECT name FROM products WHERE ID=s.id) 
FROM searloc.search('Products', 'Panel black', 10, NULL) s
ORDER by s.score DESC    
 ```
 
 e.g. 2
 ```
 DECLARE @P NVARCHAR(MAX) = 'john alb'
 SELECT
    s.id, 
    searloc.match_selection(@P, (SELECT name FROM products WHERE ID=s.id), '<b>', '</b>')  
FROM searloc.search('Customers', @P, 10, 1) s
ORDER by s.score DESC    
 ```
 
 
 
 
 
 # FUNCTION searloc.suggest
`` SELECT searloc.suggest(@TableName, @SearchText, @UserID)``

Gets the last word / prefix in @SearchText and returns the better matched word
in the records of source table.
The table you scan, must have been indexed with ``searloc.create_index`` 


Parameters:
- **@TableName NVARCHAR(MAX)** 

    The name of the table (e.g. 'products'  or 'dbo.products').
    In case you want to search in a part only of a table you can use syntax **'table_name # where_clause'**. 
    In the where_clause you can use **w0.id** to join the record
    >e.g. 'Customers# ISNULL((SELECT cancelled FROM Customers WHERE id=w0.id), 0)=0'

- **@SearchText NVARCHAR(MAX)** 

    The text that you want to search. Can be one or more whole words or prefixes. e.g. 'John Ken' will try to find the best matched word started with 'Ken'  
 
- **@UserID BIGINT** 
    
    It is optional (can be NULL). Is you set UserID this function will keep in memory history of last searches of the user, and will give him best experienced results. The history that kept for its user is temporarily stored in memory and after a short time may be released.  

Returns **NVARCHAR(MAX)** The best matched word (or NULL if nothing found) 
 
  

            

 
