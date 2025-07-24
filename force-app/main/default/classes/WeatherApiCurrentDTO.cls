public with sharing class WeatherApiCurrentDTO {

    public Location location;
    public current current;
    
    public class Location {
        public String name;
        public String region;
        public String country;
        public Decimal lat;
        public Decimal lon;
    }

    public class Current{
        public Decimal temp_c;
        public Decimal temp_f;
        public Integer is_day;
        public Condition condition;
    }

    public class Condition{
        public String text;
        public String icon;
    }
}