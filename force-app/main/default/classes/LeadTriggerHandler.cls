/*
 * The `LeadTriggerHandler` class contains methods designed to handle various business requirements around
 * the Lead object in Salesforce. This includes functionality like normalizing the title field of a lead, 
 * automatically scoring leads based on certain criteria, and auto-converting leads when certain conditions are met.
 * - Create a test class for `LeadTriggerHandler` to ensure all methods work as expected.
 * - Update the LeadTrigger class to call the `LeadTriggerHandler` methods as needed.
 *
 * Students should note:
 * - This class may contain intentional errors that need to be fixed for proper functionality.
 * - Create a corresponding test class for `LeadTriggerHandler` to ensure all methods work as expected.
 *   Both positive and negative test cases should be considered.
 *
 * Documentation on Lead conversion and Test Classes can be found here:
 * https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_dml_convertLead.htm
 * https://developer.salesforce.com/docs/atlas.en-us.apexref.meta/apexref/apex_methods_system_test.htm
 */
    public with sharing class LeadTriggerHandler {
	/* 
	 * Question 1
	 * Requirement Lead Title Normalization - handleTitleNormalization
	 * Occasionally, users input titles in a variety of ways. Streamline these titles for consistency:
	 *
	 * Criteria:
	 * - If the title contains terms such as 'vp', 'v.p.', or 'vice president',
	 *   change the title to 'Vice President'.
	 * - If the title contains terms like 'mgr', 'manage', or 'head of department',
	 *   change the title to 'Manager'.
	 * - Should the title include words like 'exec', 'chief', or 'head',
	 *   change the title to 'Executive'.
	 * - If the title contains terms like 'assist', 'deputy', or 'jr',
	 *   change the title to 'Assistant'.
	 */
	/*public static void handleTitleNormalization(List<Lead> leadsToNormalize) {
		for (Lead ld : leadsToNormalize) {
            System.debug('leadsToNormalize:'+leadsToNormalize);
			if (ld.title == 'vp' || ld.title.contains('v.p.') || ld.title.contains('vice president')) {
				ld.Title = 'Vice President';
                System.debug('Id and Title is:'+ld.Title);
			} else if (
				ld.title.contains('mgr') ||
				ld.title.contains('manage') ||
				ld.title.contains('head of department')
			) {
				ld.Title = 'Manager';
                System.debug('Manager is:'+ld.Title);
			} else if (ld.title.contains('exec') || ld.title == 'chief' || ld.title.contains('head')) {
				ld.Title = 'Executive';
                System.debug('Executive:'+ld.Title);
			} else if (ld.title.contains('assist') || ld.title.contains('deputy') || ld.title == 'jr') {
				ld.Title = 'Assistant';
                System.debug('Assistant:'+ld.Title);
			}
		}
	}*/
        public static void handleTitleNormalization(List<Lead> leadsToNormalize) {
    for (Lead ld : leadsToNormalize) {
        System.debug('leadsToNormalize: ' + leadsToNormalize);
        if (ld.Title != null) { // Null check for Title
            if (ld.Title == 'vp' || ld.Title.contains('v.p.') || ld.Title.contains('vice president')) {
                ld.Title = 'Vice President';
                System.debug('Id and Title is: ' + ld.Title);
            } else if (
                ld.Title.contains('mgr') ||
                ld.Title.contains('manage') ||
                ld.Title.contains('head of department')
            ) {
                ld.Title = 'Manager';
                System.debug('Manager is: ' + ld.Title);
            } else if (ld.Title.contains('exec') || ld.Title == 'chief' || ld.Title.contains('head')) {
                ld.Title = 'Executive';
                System.debug('Executive: ' + ld.Title);
            } else if (ld.Title.contains('assist') || ld.Title.contains('deputy') || ld.Title == 'jr') {
                ld.Title = 'Assistant';
                System.debug('Assistant: ' + ld.Title);
            }
        } else {
            System.debug('Title is null for Lead Id: ' + ld.Id);
        }
    }
}


	/* 
	 * Question 2
	 * Requirement Auto Lead Scoring - handleAutoLeadScoring
	 * Implement logic to automatically assign scores to leads based on specific criteria.
	 * 18 should be highest possible score a lead can have.
	 *
	 * Criteria:
	 * - If the lead source is from the website and an email exists, increment score by 3 points.
	 * - If the lead provides a phone number, increment score by 5 points.
	 * - If the lead belongs to the 'Technology' industry, increment score by another 10 points.
	 */
	public static void handleAutoLeadScoring(List<Lead> leadsToScore) {
		for (Lead ld : leadsToScore) {
            System.debug('LeadScore:'+leadsToScore);
			Integer score = 0;
            System.debug('Score:'+ score);

			// Check and add points based on the specified conditions
			if (ld.LeadSource == 'Website' && ld.Email != null) {
				score += 3;//Score = score+3;
                System.debug('score:'+score);
			}

			if (ld.Phone != null) {
				score += 5;
                 System.debug('score:'+score);
			}

			if (ld.Industry == 'Technology') {
				score += 10;
                 System.debug('score:'+score);
			}

			ld.Lead_Score__c = Math.min(score ,18); // Set the computed score back to the lead
              System.debug('score:'+score);
		}
	}

	/* 
	 * Question 3
	 * Requirement Automatic Lead Conversion Based on Email Match - handleLeadAutoConvert
	 * Whenever a new Lead is created or an existing Lead's email address is updated,
	 * check for a matching Contact based on the email address. If a single matching
	 * Contact is identified, auto-convert the Lead.
	 * Use the Salesforce report Converted Lead to verify that the Lead was converted to the correct Contact.
	 *
	 * Criteria:
	 * - Monitor the "Email" field on the Lead object for creation or updates.
	 * - On Lead creation or email update, search the Contact object for records with the
	 *   same email address.
	 * - If a single matching Contact is identified:
	 *     - Auto-convert the Lead.
	 *     - Merge the Lead details with the existing Contact, ensuring that crucial
	 *       Contact information is preserved.
	 * - If multiple Contacts with the same email are found or no match is identified,
	 *   leave the Lead unconverted.
	 * 
	 * Hint: 
	 * - One of the errors is recursion related. Check if the lead is already converted or check if the email has changed/is null
	 * - One of the errors is map related. Make sure you are using the correct contact map key
	 */
	/*public static void handleLeadAutoConvert(List<Lead> leads) {
		// Step 1: Gather all lead emails
        Map<Id,String> leadToEmailMap = new Map<Id,String>();
        System.debug('LeadToEmailMap is' +leadToEmailMap);
		for (Lead lead : leads) {
            if(lead.Email != null && !lead.IsConverted){
			leadToEmailMap.put(lead.Id, lead.Email);
                 System.debug('LeadToEmailMap1 is' +leadToEmailMap);
		}
        }
        if(leadToEmailMap.isEmpty()){
             System.debug('LeadToEmailMap2 is' +leadToEmailMap);
            return;
        }

		// Step 2: Find matching contacts based on email
		Map<String, Contact> emailToContactMap = new Map<String, Contact>();
		for (Contact c : [SELECT Id, Email, AccountId FROM Contact WHERE Email IN :leadToEmailMap.values()]) {
             System.debug('c is' +c);
			if (!emailToContactMap.containsKey(c.Email)) {
				emailToContactMap.put(c.Email, c);
			} else {
				// If we found another contact with the same email, we don't auto-convert.
				// So we remove the email from the map.
				 System.debug('emailToContactMap is' +emailToContactMap);
				emailToContactMap.remove(c.Email);
			}
		}

		// Step 3: Auto-convert leads
		List<Database.LeadConvert> leadConverts = new List<Database.LeadConvert>();
		LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted = TRUE LIMIT 1];
         System.debug('convertStatus is' +convertStatus);
		for (Id leadId : leadToEmailMap.keySet()) {
            String leadEmail = leadToEmailMap.get(leadId);
             System.debug('LeadEmail is' +leadEmail);
			if (emailToContactMap.containsKey(leadEmail)) {
				Database.LeadConvert lc = new Database.LeadConvert();
				lc.setLeadId(leadId);
				lc.setContactId(emailToContactMap.get(leadEmail).Id); // Use existing Contact Id
				lc.setAccountId(emailToContactMap.get(leadEmail).AccountId); // Use existing Account Id
				lc.setDoNotCreateOpportunity(true); // Assuming we don't want to create an opportunity
				lc.setConvertedStatus(convertStatus.MasterLabel); // Set the converted status
				leadConverts.add(lc);
                 System.debug('lc is' +lc);
			}
		}

		if (!leadConverts.isEmpty()) {
			List<Database.LeadConvertResult> lcrs = Database.convertLead(leadConverts);
            for(Database.leadConvertResult res : lcrs){
                 System.debug('res is' +res);
                if(!res.isSuccess()){
                    System.debug('Lead Conversion failed for lead Id' +res.getLeadId() + 'Error' +res.getErrors());
                }
            }
		}
	}*/
        public static void handleLeadAutoConvert(List<Lead> leads) {
    // Step 1: Gather all lead emails
    Map<Id, String> leadToEmailMap = new Map<Id, String>();
    System.debug('LeadToEmailMap is ' + leadToEmailMap);
    for (Lead lead : leads) {
        if (lead.Email != null && !lead.IsConverted) {
            leadToEmailMap.put(lead.Id, lead.Email);
            System.debug('LeadToEmailMap1 is ' + leadToEmailMap);
        }
    }
    if (leadToEmailMap.isEmpty()) {
        System.debug('LeadToEmailMap2 is ' + leadToEmailMap);
        return;
    }

    // Step 2: Find matching contacts based on email
    Map<String, Contact> emailToContactMap = new Map<String, Contact>();
    for (Contact c : [SELECT Id, Email, AccountId FROM Contact WHERE Email IN :leadToEmailMap.values()]) {
        System.debug('c is ' + c);
        if (!emailToContactMap.containsKey(c.Email)) {
            emailToContactMap.put(c.Email, c);
        } else {
            // If we found another contact with the same email, we don't auto-convert.
            // So we remove the email from the map.
            System.debug('emailToContactMap is ' + emailToContactMap);
            emailToContactMap.remove(c.Email);
        }
    }

    // Step 3: Auto-convert leads
    List<Database.LeadConvert> leadConverts = new List<Database.LeadConvert>();
    LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted = TRUE LIMIT 1];
    System.debug('convertStatus is ' + convertStatus);
    for (Id leadId : leadToEmailMap.keySet()) {
        String leadEmail = leadToEmailMap.get(leadId);
        System.debug('LeadEmail is ' + leadEmail);
        if (emailToContactMap.containsKey(leadEmail)) {
            Database.LeadConvert lc = new Database.LeadConvert();
            lc.setLeadId(leadId);
            lc.setContactId(emailToContactMap.get(leadEmail).Id); // Use existing Contact Id
            lc.setAccountId(emailToContactMap.get(leadEmail).AccountId); // Ensure AccountId is set
            lc.setDoNotCreateOpportunity(true); // Assuming we don't want to create an opportunity
            lc.setConvertedStatus(convertStatus.MasterLabel); // Set the converted status
            leadConverts.add(lc);
            System.debug('lc is ' + lc);
        }
    }

    if (!leadConverts.isEmpty()) {
        List<Database.LeadConvertResult> lcrs = Database.convertLead(leadConverts);
        for (Database.LeadConvertResult res : lcrs) {
            System.debug('res is ' + res);
            if (!res.isSuccess()) {
                System.debug('Lead Conversion failed for lead Id ' + res.getLeadId() + ' Error ' + res.getErrors());
            }
        }
    }
}

}