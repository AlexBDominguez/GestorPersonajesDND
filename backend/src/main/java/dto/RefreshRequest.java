package dto;

public class RefreshRequest {
    private String refreshToken;
    private String deviceInfo;

    public RefreshRequest() {}

    public String getRefreshToken()              { return refreshToken; }
    public void   setRefreshToken(String t)      { this.refreshToken = t; }
    public String getDeviceInfo()                { return deviceInfo; }
    public void   setDeviceInfo(String d)        { this.deviceInfo = d; }
}
