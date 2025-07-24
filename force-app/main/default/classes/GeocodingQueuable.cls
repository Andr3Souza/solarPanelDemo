public with sharing class GeocodingQueuable implements Queueable, Database.AllowsCallouts {
    private Integer batchSize;
    private Integer startIndex = 0; 
    public Installation__c[] installations; 
    CalloutConfig__mdt calloutConfig = [SELECT Id, BatchSize__c FROM CalloutConfig__mdt WHERE DeveloperName = 'GeocodingApi'];
    WeatherApi__mdt weatherConfig = [SELECT Id,Endpoint__c, Key__c FROM WeatherApi__mdt WHERE DeveloperName = 'OpenCage'];

    public GeocodingQueuable(Installation__c[] installations) {
        this.installations = installations;
        this.batchSize = Integer.valueOf(this.calloutConfig.BatchSize__c);
    }

    public void execute(QueueableContext context) {
        Integer endIndex = Math.min(startIndex + batchSize, installations.size());
        
        Installation__c[] currentInstallations = new Installation__c[]{};
        for (Integer i = startIndex; i < endIndex; i++) {
            currentInstallations.add(installations[i]);
        }
        processBatch(currentInstallations);
            
        if (endIndex < installations.size()) {
            this.startIndex = endIndex; 
            System.enqueueJob(this); 
        }
    }

    private void processBatch(Installation__c[] batchInstallations) {
        GeocodingService geocodingService = new GeocodingService();
        try {
            geocodingService.getGeocodingForInstallation(batchInstallations, weatherConfig);
            
        } catch (Exception e) {
            System.debug(e.getMessage());
            
        }
    }
}