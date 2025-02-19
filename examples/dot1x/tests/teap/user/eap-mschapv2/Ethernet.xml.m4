<?xml version="1.0"?>
<LANProfile xmlns="http://www.microsoft.com/networking/LAN/profile/v1">
  <MSM>
    <security>
      <OneXEnforced>true</OneXEnforced>
      <OneXEnabled>true</OneXEnabled>
      <OneX xmlns="http://www.microsoft.com/networking/OneX/v1">
        <cacheUserData>true</cacheUserData>
        <!-- Win10 needs 'machineOrUser' here, Win11 is fine with both 'user' and 'machineOrUser' -->
        <authMode>machineOrUser</authMode>
        <EAPConfig>
          <EapHostConfig xmlns="http://www.microsoft.com/provisioning/EapHostConfig">
            <EapMethod>
              <Type xmlns="http://www.microsoft.com/provisioning/EapCommon">55</Type>
              <VendorId xmlns="http://www.microsoft.com/provisioning/EapCommon">0</VendorId>
              <VendorType xmlns="http://www.microsoft.com/provisioning/EapCommon">0</VendorType>
              <AuthorId xmlns="http://www.microsoft.com/provisioning/EapCommon">311</AuthorId>
            </EapMethod>
            <Config xmlns="http://www.microsoft.com/provisioning/EapHostConfig">
              <EapTeap xmlns="http://www.microsoft.com/provisioning/EapTeapConnectionPropertiesV1">
                <ServerValidation>
                  <ServerNames>SERVERNAMES</ServerNames>
                  <!-- Windows 10 expects a SHA256 here, Windows 11 is happy with either SHA1 or SHA256 -->
                  <TrustedRootCAHash>CAHASH2</TrustedRootCAHash>
                  <DisablePrompt>true</DisablePrompt>
                  <DownloadTrustedServerRoot>false</DownloadTrustedServerRoot>
                </ServerValidation>
                <Phase2Authentication>
                  <InnerMethodConfig>
                    <EapHostConfig xmlns="http://www.microsoft.com/provisioning/EapHostConfig">
                      <EapMethod>
                        <Type xmlns="http://www.microsoft.com/provisioning/EapCommon">26</Type>
                        <VendorId xmlns="http://www.microsoft.com/provisioning/EapCommon">0</VendorId>
                        <VendorType xmlns="http://www.microsoft.com/provisioning/EapCommon">0</VendorType>
                        <AuthorId xmlns="http://www.microsoft.com/provisioning/EapCommon">0</AuthorId>
                      </EapMethod>
                      <Config xmlns="http://www.microsoft.com/provisioning/EapHostConfig">
                        <Eap xmlns="http://www.microsoft.com/provisioning/BaseEapConnectionPropertiesV1">
                          <Type>26</Type>
                          <EapType xmlns="http://www.microsoft.com/provisioning/MsChapV2ConnectionPropertiesV1">
                            <UseWinLogonCredentials>false</UseWinLogonCredentials>
                          </EapType>
                        </Eap>
                      </Config>
                    </EapHostConfig>
                  </InnerMethodConfig>
                </Phase2Authentication>
                <Phase1Identity>
                  <IdentityPrivacy>true</IdentityPrivacy>
                  <AnonymousIdentity>@example.test</AnonymousIdentity>
                </Phase1Identity>
              </EapTeap>
            </Config>
          </EapHostConfig>
        </EAPConfig>
      </OneX>
    </security>
  </MSM>
</LANProfile>
