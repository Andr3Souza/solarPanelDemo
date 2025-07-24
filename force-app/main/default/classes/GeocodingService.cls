public with sharing class GeocodingService {
    
    public void getGeocodingForInstallation(Installation__c[] installations, WeatherApi__mdt weatherConfig){
        Installation__c[] installationsToUpdate = new Installation__c[]{};
        try {
            for(Installation__c each: installations) {
                String endpoint = configureEndpoint(each.Street__c, each.City__c, each.State__c, weatherConfig);
                HttpRequest req = new HttpRequest();
                req.setEndpoint(endpoint);
                req.setMethod('GET');
    
                HttpResponse res = new Http().send(req);
                if(res.getStatusCode() == 200){
                    GeocodingDTO parsedResult = (GeocodingDTO) JSON.deserialize(res.getBody(), GeocodingDTO.class);
                    String lat = String.valueOf(parsedResult.results[0].geometry.lat); 
                    String lng = String.valueOf(parsedResult.results[0].geometry.lng);

                    Installation__c updatedIntallation = new Installation__c(
                        Id = each.Id,
                        Latitude__c = lat,
                        Longitude__c = lng
                    );
                    installationsToUpdate.add(updatedIntallation);

                }else{
                    System.debug(res.getStatusCode() + res.getBody());
                }
            }
            if(!installationsToUpdate.isEmpty()){update installationsToUpdate;}
        } catch (Exception e) {
            System.debug(e.getMessage());
        }
    }

    public String configureEndpoint(String street, String city, String state, WeatherApi__mdt weatherConfig){
        String address = EncodingUtil.urlEncode(street + ', ' + city + ', ' + state, 'UTF-8');
        String finalUrl = weatherConfig.Endpoint__c 
                            + '?q='+address
                            +'&key=' + weatherConfig.Key__c;
        return finalUrl;
    }
}