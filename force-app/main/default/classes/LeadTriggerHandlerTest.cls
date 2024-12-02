/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an org are executed whenever Apex code is deployed
 * to a production org to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production org. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the org size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class LeadTriggerHandlerTest {

    @testSetup
    static void setupTestData() {
        List<Lead> leads = new List<Lead>{
            new Lead(FirstName='John', LastName='Doe', Company='UniqueTech' + System.currentTimeMillis(), Title='vp', Email='test' + System.currentTimeMillis() + '@example.com', Phone='1234567890', Industry='Technology', LeadSource='Website'),
            new Lead(FirstName='Jane', LastName='Smith', Company='UniqueBiz' + System.currentTimeMillis(), Title='mgr', Email='test2' + System.currentTimeMillis() + '@example.com', Phone='9876543210', Industry='Retail', LeadSource='Referral'),
            new Lead(FirstName='Test', LastName='Coverage', Company='UniqueBizzzzz' + System.currentTimeMillis(), Title='exec', Email='test2' + System.currentTimeMillis() + '@example2.com', Phone='9876543266', Industry='Retailer', LeadSource='Referralll'),
            new Lead(FirstName='Testing', LastName='Coveraged', Company='UniqueBizzzxz' + System.currentTimeMillis(), Title='assist', Email='test21' + System.currentTimeMillis() + '@example1.com', Phone='9878543266', Industry='Retasiler', LeadSource='Refesrralll')


        };
        insert leads;

        Contact contact = new Contact(FirstName='John', LastName='Doe', Email='unique_contact' + System.currentTimeMillis() + '@example.com');
        insert contact;
    }



  
    
    @isTest
    static void testHandleTitleNormalization() {
        List<Lead> leads = [SELECT Id, Title FROM Lead];
        Test.startTest();
        LeadTriggerHandler.handleTitleNormalization(leads);
        Test.stopTest();

        for (Lead lead : leads) {
            if (lead.Title == 'vp') {
                System.assertEquals('Vice President', lead.Title, 'Title should be normalized to Vice President');
            } else if (lead.Title.contains('mgr')) {
                System.assertEquals('Manager', lead.Title, 'Title should be normalized to Manager');
            } else if (lead.Title.contains('exec')) {
                System.assertEquals('Executive', lead.Title, 'Title should be normalized to Executive');
            } else if (lead.Title.contains('assist')) {
                System.assertEquals('Assistant', lead.Title, 'Title should be normalized to Assistant');
            }
        }
    }

    @isTest
    static void testHandleAutoLeadScoring() {
        List<Lead> leads = [SELECT Id, LeadSource, Email, Phone, Industry, Lead_Score__c FROM Lead];
        Test.startTest();
        LeadTriggerHandler.handleAutoLeadScoring(leads);
        Test.stopTest();

        for (Lead lead : leads) {
            if (lead.LeadSource == 'Website' && lead.Email != null) {
                System.assert(lead.Lead_Score__c >= 3, 'Score should account for website source and email presence');
            }
            if (lead.Phone != null) {
                System.assert(lead.Lead_Score__c >= 5, 'Score should account for phone presence');
            }
            if (lead.Industry == 'Technology') {
                System.assert(lead.Lead_Score__c >= 10, 'Score should account for technology industry');
            }
            System.assert(lead.Lead_Score__c <= 18, 'Score should not exceed the maximum limit');
        }
    }

@isTest
static void testHandleLeadAutoConvert() {
    delete [SELECT Id FROM Contact WHERE Email = 'convert@example.com'];
    delete [SELECT Id FROM Lead WHERE Email = 'convert@example.com'];

    Account accountToUse = new Account(Name = 'Test Account');
    insert accountToUse;

    Lead leadToConvert = new Lead(
        FirstName = 'Convertsddd',
        LastName = 'Tesddt',
        Company = 'ConvertddCorp',
        Email = 'convert@example.com',  
        IsConverted = false
    );
    insert leadToConvert;

   
    Contact matchingContact = new Contact(
        FirstName = 'Convert',
        LastName = 'Contact',
        Email = leadToConvert.Email, 
        AccountId = accountToUse.Id 
    );
    insert matchingContact;

   
    LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted = true LIMIT 1];
    System.assertNotEquals(null, convertStatus, 'Conversion status should exist.');

   
    List<Lead> leads = [SELECT Id, Email, IsConverted FROM Lead WHERE Email != null];
    Test.startTest();
    LeadTriggerHandler.handleLeadAutoConvert(leads);
    Test.stopTest();

    
    Lead convertedLead = [SELECT Id, IsConverted FROM Lead WHERE Id = :leadToConvert.Id];
    System.assertEquals(true, convertedLead.IsConverted, 'Lead should be converted.');
}


}