/**
 * The DMLOperations class serves as a deep dive into Data Manipulation Language (DML) in Apex.
 * It covers fundamental DML operations such as insert, update, upsert, and delete.
 *
 * This class introduces developers to the concept of manipulating Salesforce records in Apex.
 * It discusses how to use DML operations to create, update, and delete records.
 * This class uses standard Salesforce objects like Account, Contact, and Opportunity for demonstration.
 *
 * Topics covered in this class include:
 * - Understanding how to use insert DML operation to create records in Salesforce.
 * - Understanding how to use update and upsert DML operations to update existing records in Salesforce.
 * - Understanding how to use delete DML operation to remove records from Salesforce.
 *
 * Users of this class can expect to gain a strong understanding of DML operations in Apex and
 * be prepared for more advanced topics in Salesforce development.
 *
 * The methods within this class serve as practical examples of different DML operations,
 * allowing developers to learn through practice and examples.
 *
 * @author Rodrigo Estran
 */


public with sharing class DMLOperations {

    /**
     * Question 1
     * Create a new Account object and inserts it into the database.
     * The Account will have a random name for uniqueness.
     * @return The Id of the newly created Account.
     */
    public static Id insertNewAccount() {
        // Create a new Account instance
        Account acc = new Account();
        // Set some fields on the Account
        acc.Name = 'Account ' + Math.random();
        acc.Phone = '1234567890';
        acc.Website = 'www.DMLexample.com';
        // Insert the Account into the database
        // I reseearched and added this check based on a warning displyed in VS code
        if (!Schema.sObjectType.Account.isCreateable()) {
            throw new DmlException('Account is not createable');
        }
        insert acc;
        // Return the Id of the newly created Account
        return acc.Id;
    }

    /**
     * Question 2
     * Create a new Account with the specified name and industry provided.
     * @param name The name of the account to be created.
     * @param industry The industry of the account to be created.
     */
    public static void createAccount(String name, String industry) {
        // Create a new Account and set the fields inline
        Account acc = new Account(Name = name, Industry = industry);
        // Insert the Account
        if (!Schema.sObjectType.Account.isCreateable()) {
            throw new DmlException('Account is not createable');
        }
        insert acc;
    }

    
    /**
     * Question 3
     * Create a new Contact and link it to the Account id provided then inserts it into the database.
     * @param accountId The Id of the Account to link the Contact to.
     * @return The Id of the newly created Contact.
     */
    public static Id insertNewContact(Id accountId) {
        // Create a new Contact instance
        Contact contact = new Contact();
        // Set some fields on the Contact
        contact.FirstName = 'John';
        contact.LastName = 'Doe ' + Math.random();
        // Set the AccountId field to the given accountId
        contact.AccountId = accountId;
        // Insert the Contact into the database
        if (!Schema.sObjectType.Contact.isCreateable()) {
            throw new DmlException('Contact is not createable');
        }
        insert contact;
        // Return the Id of the newly created Contact
        return contact.Id;
    }

    /**
     * Question 4
     * Update the last name of a Contact in the database.
     * Resource: https://developer.salesforce.com/docs/atlas.en-us.soql_sosl.meta/soql_sosl/sforce_api_calls_soql.htm
     * @param contactId The Id of the Contact to update.
     * @param newLastName The new last name for the Contact.
     */
    public static void updateContactLastName(Id contactId, String newLastName) {
        // Retrieve the Contact from the database
        // [SELECT Id FROM Contact WHERE Id = :contactId]
        //Added validations to test Schema class methods and other validations
        if(contactId == null || String.isBlank(newLastName)){return;}
        if (!Schema.sObjectType.Contact.isAccessible() ||
        !Schema.sObjectType.Contact.isUpdateable() ||
        !Schema.sObjectType.Contact.fields.LastName.isUpdateable()) {
        return;
        }
        Contact updateContact = [SELECT Id, LastName FROM Contact WHERE Id = :contactId];
        // Update the Contact's last name
        if (updateContact == null){return;}
            updateContact.LastName = newLastName;
            update updateContact;
    }

    /**
     * Question 5
     * Update the stage of an Opportunity in the database.
     * Resource: https://developer.salesforce.com/docs/atlas.en-us.soql_sosl.meta/soql_sosl/sforce_api_calls_soql.htm
     * @param oppId The Id of the Opportunity to update.
     * @param newStage The new stage for the Opportunity.
     */
    public static void updateOpportunityStage(Id oppId, String newStage) {
            // Retrieve the Opportunity from the database
            // [SELECT Id FROM Opportunity WHERE Id = :oppId]
            //Check the schema to check if the object is accessible, updateable and the field is updateable
            if(Schema.sObjectType.Opportunity.isAccessible() &&
            Schema.sObjectType.Opportunity.isUpdateable() &&
            Schema.sObjectType.Opportunity.fields.StageName.isUpdateable()){
            Opportunity updateOpp = [SELECT Id, StageName FROM Opportunity WHERE Id = :oppId];
            //Check if the stage is null or the same as the new stage
            if (updateOpp.StageName == null || updateOpp.StageName == newStage){return;}
                updateOpp.StageName = newStage;
            // Update the Opportunity in the database
            update updateOpp;
        }
    }

    /**
     * Question 6
     * Update the Account's Name and Industry given an Account Id.
     * Resource: https://developer.salesforce.com/docs/atlas.en-us.soql_sosl.meta/soql_sosl/sforce_api_calls_soql.htm
     * @param accountId The Id of the account to be updated.
     * @param newName The new name for the account.
     * @param newIndustry The new industry for the account.
     */
    public static void updateAccountFields(Id accountId, String newName, String newIndustry) {
        // Query the account
        // [SELECT Id FROM Account WHERE Id = :accountId]
        Account updateAccount = [SELECT Id, Name, Industry FROM Account WHERE Id = :accountId];
        // Check if the account is null
        if (updateAccount == null || newName == null){return;}
        // Check if the new name is null or the same as the current name
        if (!Schema.SObjectType.Account.isUpdateable() || !Schema.sObjectType.Account.fields.Name.isUpdateable()||
            !Schema.sObjectType.Account.fields.Industry.isUpdateable()){return;}
        updateAccount.Name = newName;
        updateAccount.Industry = newIndustry;
        update updateAccount;
    }


    /**
     * Question 7
     * Create or updates an Opportunities
     * The Opportunity's Stage is set to Qualification.
     * The Opportunity's Close Date is set to 3 months from today.
     * The Opportunity's Amount is set to 50000.
     * @param list of Opportunities to be changed then upserted.
     */
    public static void upsertOpportunityList(List<Opportunity> opportunities) {
        // Check if the list is null or empty
        if (opportunities == null || opportunities.isEmpty()){return;}
        // Loop through each Opportunity in the list
        // Set the Opportunity's Stage to Qualification
        // Set the Opportunity's Close Date to 3 months from today
        // Set the Opportunity's Amount to 50000
        for(Opportunity opp : opportunities){
            opp.StageName = 'Qualification';
            opp.CloseDate = Date.today().addMonths(3);
            opp.Amount = 50000;
        }
        // Upsert the opportunities List so that records are either updated or created
        if(Schema.sObjectType.Opportunity.isUpdateable() && Schema.sObjectType.Opportunity.isCreateable()){
        upsert opportunities;
        }
    }

    /**
     * Question 8
     * Insert or update opportunities from list of names.
     * Associate the Opportunities with account that has the name accountName.
     * There should be an Opportunity for each name provided in the list.
     * HINT: The account may or may not exists in the database but is required for opportunity creation. Consider how upsert operation can help with this.
     * HINT: There should not be duplicate opportunites based on the name
     * @param accountName The name of the Account.
     * @param oppNames The list of Opportunity names.
     */
    public static void upsertOpportunities(String accountName, List<String> oppNames) {
        if(String.isBlank(accountName) || oppNames == null || oppNames.isEmpty()){return;}
        // Remove blanks + duplicates
        Set<String> uniqueOppNames = new Set<String>();
        for (String oppName : oppNames) {
            if (!String.isBlank(oppName)) {
                uniqueOppNames.add(oppName.trim());
            }
        }
        if (uniqueOppNames.isEmpty()) {
        return;
        }
        // Query for the Account
        Account acct;
        List<Account> accounts = [SELECT Id FROM Account WHERE Name = :accountName];
        // Check if the Account exists)
        if (accounts.isEmpty()) {
            acct = new Account(Name = accountName);
            insert acct;
        } else {
            acct = accounts[0];
        }
         // Query existing Opportunities by name
        Map<String, Opportunity> existingOppsByName = new Map<String, Opportunity>();
        for (Opportunity opp : [
            SELECT Id, Name, AccountId, StageName, CloseDate
            FROM Opportunity
            WHERE AccountId = :acct.Id AND Name IN :uniqueOppNames]) {
         existingOppsByName.put(opp.Name, opp);
        }
        // Loop through each Opportunity name
        // Create an Opportunity with the given name
        // Add the Opportunity to the list
        List<Opportunity> oppsToUpsert = new List<Opportunity>();
        for (String oppName : uniqueOppNames) {
            Opportunity opp;
            if (existingOppsByName.containsKey(oppName)) {
                // Update existing
                opp = existingOppsByName.get(oppName);
                opp.AccountId = acct.Id;
            } else {
                    // Insert new opp.
                    opp = new Opportunity(
                        Name = oppName,
                        AccountId = acct.Id,
                        StageName = 'Prospecting',
                        CloseDate = Date.today().addDays(30)
                    );
                }
                oppsToUpsert.add(opp);
        }
        if (!Schema.sObjectType.Opportunity.isCreateable() || !Schema.sObjectType.Opportunity.isUpdateable()) {
            throw new DmlException('Case is not createable');
        }
        upsert oppsToUpsert;
    }
    
    /**
     * Question 9
	 * Upserts an Account with the specified name.
	 * If an Account with the given name already exists, update the description to "Updated Account".
	 * If no such Account exists, it creates a new one and sets the description to "New Account".
	 * @param accountName The name of the Account to be upserted.
	 * @return The Account that was upserted.
	 */
	public static Account upsertAccount(String accountName) {
		
        if(String.isBlank(accountName)){return null;}
        // Query for the Account
		List<Account> accounts = [SELECT Id, Name FROM Account WHERE Name = :accountName LIMIT 1];
        if (accounts.isEmpty()) {
            Account acc = new Account(Name = accountName, Description = 'New Account');
            accounts.add(acc);
        }else{
                    accounts[0].Description = 'Updated Account';
        }
                upsert accounts;
                return accounts[0];
	}

    /**
     * Creates or updates Account records in bulk based on the provided Account names.
     * Existing Accounts are queried by Name and their Description is updated to 'Updated Account'.
     * New Account records are created for names not found and assigned Description = 'New Account'.
     *
     * @param accountNames Set of Account names to process. Null, blank, and whitespace-only values are ignored.
     * @return Map<String, Account> A map keyed by trimmed Account Name containing the Accounts that were upserted.
     */
    public static Map<String, Account> upsertAccountsBulk(Set<String> accountNames) {
         Map<String, Account> accountsByName = new Map<String, Account>();
         //Return an empty map if input variable is null or empty.
        if(accountNames == null || accountNames.isEmpty()){return accountsByName;}

        //use only unique names, remove blanks and trim spaces.
        Set<String> cleanNames = new Set<String>();
        for (String nameVal : accountNames) {
            if (!String.isBlank(nameVal)) {
                cleanNames.add(nameVal.trim());
            }
        }
        if (cleanNames.isEmpty()) {
            return accountsByName;
        }
        // Query for the accounts and add to map.
        for(Account acc : [SELECT Id, Name, Description FROM Account WHERE Name IN :cleanNames]){
            accountsByName.put(acc.Name, acc);
        }
        // Loop through each Account name if it is not in the map, add it to the map.
        for (String accountName : cleanNames) {
            if(accountsByName.containsKey(accountName)){
                accountsByName.get(accountName).Description = 'Updated Account';
            }else{
                accountsByName.put(accountName, new Account(Name = accountName, Description = 'New Account'));
            }
        }
        upsert accountsByName.values();

        return accountsByName;
    }

    /**
     * Question 10
	 * Manage the association between Contacts and Accounts
	 * Ensure that for each Contact in the provided list, there is a corresponding Account Name that matches the Contact's last name.
	 * If such an Account does not exist, the method creates it; if it does, the method ensures the Contact is associated with it. (Hint: use previous upsertAccount method - this may cause bad practices but for learning purposes it's okay.)
     * Example Contact.LastName = 'Doe' Link to Account.Name = 'Doe' 
     * Example Contact.LastName = 'Jane' Link to Account.Name = 'Jane'
	 * @param contactsToUpsert List of Contacts to be upserted and linked to accounts.
	 */
	public static void upsertAccountsWithContacts(List<Contact> contactsToUpsert) {
        if (contactsToUpsert == null || contactsToUpsert.isEmpty()){return;}
		// Loop through each Contact
        Set<String> accountNames = new Set<String>();
        for (Contact c : contactsToUpsert) {
            if (String.isBlank(c.LastName)) { continue; }
            // Extract the Account Name from Contact's LastName
            accountNames.add(c.LastName.trim());
        }
        // Get the account based on the name or create one if it doesn't exist
        Map<String, Account> accountsByName = upsertAccountsBulk(accountNames);
		// Link the Contact to its Account using the Account Id
        if(!accountsByName.isEmpty()){
            for(Contact c : contactsToUpsert){
                if (String.isBlank(c.LastName)){continue;}
                Account acc = accountsByName.get(c.LastName.trim());
                if (acc != null) {
                    c.AccountId = acc.Id;
                }
            }
        }
		// Upsert the Contacts
        upsert contactsToUpsert;
	}

    /**
     * Question 11
     * Insert a list of Leads and then deletes them.
     * @param leadNames The list of Lead names to be inserted.
     */
    public static void insertAndDeleteLeads(List<String> leadNames) {
        if (leadNames == null || leadNames.isEmpty()){return;}
        // Loop through each Lead name
        List<Lead> leadsToInsert = new List<Lead>();
        for (String leadName : leadNames) {
            if (String.isBlank(leadName)) { continue; }
            // Create a new Lead and set the fields inline
            Lead lead = new Lead(LastName = leadName, Company = 'Test Company');
            leadsToInsert.add(lead);
        }

        // Insert the Leads
        if (leadsToInsert.isEmpty()) { return; }
        if (!Schema.sObjectType.Lead.isCreateable()) {
            throw new DmlException('Lead is not createable');
        }
        insert leadsToInsert;

        // Delete the Leads
        if (!Schema.sObjectType.Lead.isDeletable()) {
            throw new DmlException('Lead is not deletable');
        }
        delete leadsToInsert;
    }


    /**
     * Question 12
     * Dynamically create the number of cases and relate it to the accountId, then deletes them.
     * @param accountId The account for which the cases will be created and then deleted.
     * @param numOfCases The number of cases to create.
     */
    public static void createAndDeleteCases(String accountId, Integer numOfCases) {
        if(String.isBlank(accountId) || numOfCases == null || numOfCases <= 0){return;}
        // Create the cases
        List<Case> casesToInsert = new List<Case>();
        for (Integer i = 0; i < numOfCases; i++) {
            Case c = new Case(AccountId = accountId, Subject = 'Test Case ' + i, Status = 'Closed');
            casesToInsert.add(c);
        }
        // Insert the cases
        if (!Schema.sObjectType.Case.isCreateable()) {
            throw new DmlException('Case is not createable');
        }
        insert casesToInsert;

        if (!Schema.sObjectType.Case.isDeletable()) {
            throw new DmlException('Case is not deletable');
        }
        // Delete the cases
        delete casesToInsert;
    
    }
}