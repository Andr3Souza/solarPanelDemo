public with sharing class GeocodingDTO {
    public List<Result> results;

    public class Result{
        public geometry geometry;
    }

    public class Geometry{
        public Decimal lat;
        public Decimal lng;
    }
}