trigger contactOnfidoTrigger on Contact (after insert) {
    for(ID newContact : trigger.newMap.keySet()){
    //System.enqueueJob(new OnfidoCalloutQueueable(newContact));
    }
}