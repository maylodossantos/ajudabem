package com.ajudabem.api.services.care;

public final class GeoDistance {

    private static final double EARTH_RADIUS_KM = 6371.0;

    private GeoDistance() {
    }

    public static double km(double fromLatitude, double fromLongitude, double toLatitude, double toLongitude) {
        double dLat = Math.toRadians(toLatitude - fromLatitude);
        double dLon = Math.toRadians(toLongitude - fromLongitude);
        double a = Math.pow(Math.sin(dLat / 2), 2)
                + Math.cos(Math.toRadians(fromLatitude)) * Math.cos(Math.toRadians(toLatitude))
                * Math.pow(Math.sin(dLon / 2), 2);
        return 2 * EARTH_RADIUS_KM * Math.asin(Math.sqrt(a));
    }
}
