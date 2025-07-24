public with sharing class SolarPanelsWeatherController {
    
    @AuraEnabled(cacheable=true)
    public static List<String> getDistinctCountries() {
        List<String> countries = new List<String>();
        for (AggregateResult ar : [
            SELECT Country__c FROM Installation__c WHERE Country__c != null GROUP BY Country__c
        ]) {
            countries.add((String)ar.get('Country__c'));
        }
        return countries;
    }

    @AuraEnabled(cacheable=true)
    public static List<String> getDistinctCities(String country) {
        List<String> cities = new List<String>();
        for (AggregateResult ar : [
            SELECT City__c FROM Installation__c WHERE Country__c = :country AND City__c != null GROUP BY City__c
        ]) {
            cities.add((String)ar.get('City__c'));
        }
        return cities;
    }

    @AuraEnabled
    public static List<Installation__c> getInstallations(String country, String city) {
        String filterCountry = '%' + country + '%';
        String filterCity = '%' + city + '%';

        String baseQuery = 'SELECT Id, Account__r.Name ,Street__c ,City__c ,State__c ,InstallationDate__c ,WeatherLastUpdate__c ,WeatherCondition__c ,FTemperature__c ,CTemperature__c , ConditionIconURL__c FROM Installation__c WHERE ';
        List<String> conditions = new List<String>();
    
        if (!String.isBlank(country)) {
            conditions.add('Country__c LIKE :filterCountry');
        }
        if (!String.isBlank(city)) {
            conditions.add('City__c LIKE :filterCity');
        }
    
        String finalQuery = baseQuery + (conditions.isEmpty() ? 'Id != null' : String.join(conditions, ' AND '));
        return Database.query(finalQuery);
    }

    @AuraEnabled
    public static String getCurrentWeatherForInstallations(Id installationId){
        try {
            Installation__c installation = [SELECT Id, City__c,Street__c,  State__c, Country__c, Latitude__c, Longitude__c FROM Installation__c WHERE Id =:InstallationId];
            WeatherAPIService weatherService = new WeatherAPIService(installation);
            
            return JSON.serialize(weatherService.getCurrentWeatherForInstallations());
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static String getForecastWeatherForInstallations(Id installationId){
        try {
            Installation__c installation = [SELECT Id, City__c,Street__c,  State__c, Country__c, Latitude__c, Longitude__c FROM Installation__c WHERE Id =:InstallationId];
            WeatherAPIService weatherService = new WeatherAPIService(installation);
            
            return JSON.serialize(weatherService.getForecastWeatherForInstallations());
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}