public with sharing class WeatherAPIService {
    public WeatherApi__mdt weatherConfig;
    public Installation__c currentInstallation;

    public WeatherAPIService(Installation__c installation){
        this.weatherConfig = [SELECT Id,Endpoint__c, Key__c FROM WeatherApi__mdt WHERE DeveloperName = 'WeatherApi'];
        this.currentInstallation = installation;
    }
    
    public WeatherApiCurrentDTO getCurrentWeatherForInstallations(){
        try {
            String endpoint = configureEndpoint('current');
            HttpRequest req = new HttpRequest();
            req.setEndpoint(endpoint);
            req.setMethod('GET');
            HttpResponse res = new Http().send(req);
            
            if(res.getStatusCode() == 200){
                WeatherApiCurrentDTO parsedResult = (WeatherApiCurrentDTO) JSON.deserialize(res.getBody(), WeatherApiCurrentDTO.class);
                Installation__c installationToUpdate = new Installation__c(
                    Id = currentInstallation.Id,
                    CTemperature__c = parsedResult.current.temp_c,
                    FTemperature__c = parsedResult.current.temp_f,
                    LastWeatherUpdate__c = System.now(),
                    WeatherCondition__c = parsedResult.current.condition.text,
                    ConditionIconURL__c = parsedResult.current.condition.icon
                );

                update installationToUpdate;
                return parsedResult;
        }else{
            System.debug(res.getStatusCode() + res.getBody());
            throw new AuraHandledException(res.getStatusCode() + res.getBody());
        }
            
        } catch (Exception e ) {
            System.debug('Error in getForecastWeatherForInstallations: ' + e.getMessage());
            throw new AuraHandledException('error in getForecastWeatherForInstallations: ' + e.getMessage());
        }
    }

    public WeatherApiForecastDTO getForecastWeatherForInstallations(){
        try {
            String endpoint = configureEndpoint('forecast');
            HttpRequest req = new HttpRequest();
            req.setEndpoint(endpoint);
            req.setMethod('GET');
            HttpResponse res = new Http().send(req);
            
            if(res.getStatusCode() == 200){
                WeatherApiForecastDTO parsedResult = (WeatherApiForecastDTO) JSON.deserialize(res.getBody(), WeatherApiForecastDTO.class);
                return parsedResult;
            }else{
                System.debug(res.getStatusCode() + res.getBody());
                throw new AuraHandledException(res.getStatusCode() + res.getBody());
            }
        } catch (Exception e) {
            System.debug('Error in getForecastWeatherForInstallations: ' + e.getMessage());
            throw new AuraHandledException('error in getForecastWeatherForInstallations: ' + e.getMessage());
        }
    }

    public String configureEndpoint(String typeOfRequisition){
        if(typeOfRequisition == 'current'){
        return weatherConfig.Endpoint__c
            +typeOfRequisition+'.json'
            +'?key='+weatherConfig.Key__c
            +'&q='+currentInstallation.Latitude__c+','+currentInstallation.Longitude__c;

        }else{
            return weatherConfig.Endpoint__c
            +typeOfRequisition+'.json'
            +'?key='+weatherConfig.Key__c
            +'&q='+currentInstallation.Latitude__c+','+currentInstallation.Longitude__c
            +'&days=7&aqi=no&alerts=no';
        }
    }
}