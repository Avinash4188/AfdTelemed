public without sharing class BaselineHealthOverviewController {
    @AuraEnabled(cacheable=true)
    public static Baseline_Health_Overview__c getBaselineHealthOverview(String leadId) {
        return [Select Add_details_of_your_last_visit__c, Any_allergic_reaction_to_the_medication__c, Diastolic_Pressure__c, Height__c, High_Blood_Pressure__c, List_of_environmental_allergies_reaction__c,List_Of_Medical_Condition__c, List_Of_Medications__c, Most_Recent_Physical_Medical_Visit__c, Systolic_Pressure__c, Weight__c, What_happen_when_you_had_allergic_react__c from Baseline_Health_Overview__c where Lead__c =:leadId LIMIT 1];
    }
    
    @AuraEnabled(cacheable=true)
    public static List<String> getAllergies() {
        List<String> picklistValuesAllergies = new List<String>();
        Schema.DescribeFieldResult fieldResult = Baseline_Health_Overview__c.List_of_environmental_allergies_reaction__c.getDescribe();
        for (Schema.PicklistEntry entry : fieldResult.getPicklistValues()) {
            picklistValuesAllergies.add(entry.getLabel());
        }
        system.debug(picklistValuesAllergies);
        return picklistValuesAllergies;
    }
    
    @AuraEnabled(cacheable=true)
    public static List<String> getMedication() {
        List<String> picklistValuesMedication = new List<String>();
        Schema.DescribeFieldResult fieldResult = Baseline_Health_Overview__c.List_Of_Medications__c.getDescribe();
        for (Schema.PicklistEntry entry : fieldResult.getPicklistValues()) {
            picklistValuesMedication.add(entry.getLabel());
        }
        system.debug(picklistValuesMedication);
        return picklistValuesMedication;
    }
    
    @AuraEnabled(cacheable=true)
    public static List<String> getMedicalCondition() {
        List<String> picklistValuesMC = new List<String>();
        Schema.DescribeFieldResult fieldResult = Baseline_Health_Overview__c.List_Of_Medical_Condition__c.getDescribe();
        for (Schema.PicklistEntry entry : fieldResult.getPicklistValues()) {
            picklistValuesMC.add(entry.getLabel());
        }
        system.debug(picklistValuesMC);
        return picklistValuesMC;
    }
    
    @AuraEnabled
    public static Id createBaselineHealthOverview(Map<String, Object> recordInput, Baseline_Health_Overview__c recordData) {
        try {
            // Extract the leadId from the input map
            Id leadId = (Id)recordInput.get('leadId');
            
            // Check if the record already exists
            Baseline_Health_Overview__c healthOverview;

            if (recordData != null) {
                // If the recordData is provided, update it
                healthOverview = recordData;
            } else {
                // If the recordData is not provided, check if the record already exists
                healthOverview = [SELECT Id FROM Baseline_Health_Overview__c WHERE Lead__c = :leadId LIMIT 1];
                
                if (healthOverview == null) {
                    // If the record doesn't exist, create a new one
                    healthOverview = new Baseline_Health_Overview__c();
                    healthOverview.Lead__c = leadId;
                }
            }
            
            // Set field values based on the provided data
            healthOverview.Weight__c = recordData.Weight__c;
            healthOverview.Height__c = recordData.Height__c;
            healthOverview.Add_details_of_your_last_visit__c = recordData.Add_details_of_your_last_visit__c;
            healthOverview.Most_Recent_Physical_Medical_Visit__c = recordData.Most_Recent_Physical_Medical_Visit__c;
            healthOverview.Any_allergic_reaction_to_the_medication__c = (Boolean)recordInput.get('Any_allergic_reaction_to_the_medication__c');
            healthOverview.High_Blood_Pressure__c = (Boolean)recordInput.get('High_Blood_Pressure__c');
            healthOverview.What_happen_when_you_had_allergic_react__c = recordData.What_happen_when_you_had_allergic_react__c;
            healthOverview.Diastolic_Pressure__c = recordData.Diastolic_Pressure__c;
            healthOverview.Systolic_Pressure__c = recordData.Systolic_Pressure__c;
            healthOverview.List_of_environmental_allergies_reaction__c = (String)recordInput.get('List_of_environmental_allergies_reaction__c');
            healthOverview.List_Of_Medical_Condition__c = (String)recordInput.get('List_Of_Medical_Condition__c');
            healthOverview.List_Of_Medications__c = (String)recordInput.get('List_Of_Medications__c');
            healthOverview.Lead__c = (Id)recordInput.get('leadId');
            
            
            
            // Upsert the record
            upsert healthOverview;
            
            return healthOverview.Id;
        } catch (Exception ex) {
            // Handle any exceptions or errors here
            throw new AuraHandledException('Error creating/updating Baseline Health Overview record: ' + ex.getMessage());
        }
    }
    
}