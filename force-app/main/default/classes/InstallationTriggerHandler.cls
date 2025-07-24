public with sharing class InstallationTriggerHandler {

    public void beforeInsert(Installation__c[] newInstallations){
    }

    public void beforeUpdate(Installation__c[] newInstallations, Map<Id, Installation__c> oldMap){
    }

    public void afterInsert(Installation__c[] newInstallations){
        Installation__c[] availableforGeocoding = new Installation__c[]{};
        
        for(Installation__c each: newInstallations){
            if(vailidForGeocoding(each)){
                availableforGeocoding.add(each);
            }
        }
        System.enqueueJob(new GeocodingQueuable(availableforGeocoding));        
    }

    public void afterUpdate(Installation__c[] newInstallations, Map<Id, Installation__c> oldMap){
        Installation__c[] availableforGeocoding = new Installation__c[]{};
        
        for(Installation__c each: newInstallations){
            if((each.Street__c != oldMap.get(each.Id).Street__c || each.City__c != oldMap.get(each.Id).City__c || each.State__c != oldMap.get(each.Id).State__c) && vailidForGeocoding(each) ){
                availableforGeocoding.add(each);
            }
        }
        System.enqueueJob(new GeocodingQueuable(availableforGeocoding));        
    }

    public Boolean vailidForGeocoding(Installation__c installation){
       return installation.Street__c != null && installation.City__c != null && installation.State__c != null;
    }
}