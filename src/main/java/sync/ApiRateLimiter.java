package sync;

public class ApiRateLimiter {
    

    private static final long DELAY_BETWEEN_REQUESTS_MS = 500; // 1 second delay

    public static void waitBetweenRequests() {
        try {
            Thread.sleep(DELAY_BETWEEN_REQUESTS_MS);
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
            System.err.println("Rate limiter interrupted");
        }
    }

    public static void waitLonger(){
        try{
            Thread.sleep(1000); //para peticiones que requieren más tiempo, como las de clase            
        }catch (InterruptedException e) {
            Thread.currentThread().interrupt();
        }
    }
}

