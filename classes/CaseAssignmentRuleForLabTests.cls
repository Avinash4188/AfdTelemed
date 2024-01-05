public class CaseAssignmentRuleForLabTests {
    
      Map<String, String> picklistQueueMapping = new Map<String, String>{
        'Value1' => 'Queue1',
        'Value2' => 'Queue2',
        'Value100' => 'Queue100'
    };

    
     private static void getQueue() {
        
        //Group queue = [SELECT Id FROM Group WHERE Type = 'Queue' AND Name = '' LIMIT 1];
        //select id,Queue.Name from QueueSobject  where Queue.Name ='Labs'
        
    }
}