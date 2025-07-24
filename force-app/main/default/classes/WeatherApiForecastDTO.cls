public with sharing class WeatherApiForecastDTO {

    public Forecast forecast;

    public class Forecast{
        public ForecastDay[] forecastday;
    }
    
    public class ForecastDay{
        public String date_epoch;
        public Day day;
        public Astro astro;
    }

    public class Day{
        public Decimal maxtemp_c;
        public Decimal maxtemp_f;
        public Decimal mintemp_c;
        public Decimal mintemp_f;
        public Decimal avgtemp_c;
        public Decimal avgtemp_f;
    }

    public class Astro{
        public String sunrise;
        public String sunset;
        public String moonrise;
        public String moonset;
    }
}