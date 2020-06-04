Please run code in the following order:

    1. create-tables.sql            (Create tables and populates look up tables)
    2. computed-columns.sql         (Create computed columns)
    3. business-rule.sql            (Create business rules for db)
    4. look-up-stored-procedure.sql (Create stored procs for getID of a table)
    5. stored-procedures.sql        (Stored procs that are not getID)
    6. views.sql                    (Views of database)
    7. insert-tblGame.sql           (Inserts data information from external csv file)
    8. synthetic-tran.sql           (Synthetic transaction wrapper to fill database)