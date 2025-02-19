<?xml version="1.0"?>
<LANProfile xmlns="http://www.microsoft.com/networking/LAN/profile/v1">
  <MSM>
    <security>
      <OneXEnforced>true</OneXEnforced>
      <OneXEnabled>true</OneXEnabled>
      <OneX xmlns="http://www.microsoft.com/networking/OneX/v1">
        <cacheUserData>true</cacheUserData>
        <authMode>machine</authMode>
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
                        <Type xmlns="http://www.microsoft.com/provisioning/EapCommon">13</Type>
                        <VendorId xmlns="http://www.microsoft.com/provisioning/EapCommon">0</VendorId>
                        <VendorType xmlns="http://www.microsoft.com/provisioning/EapCommon">0</VendorType>
                        <AuthorId xmlns="http://www.microsoft.com/provisioning/EapCommon">0</AuthorId>
                      </EapMethod>
                      <Config xmlns="http://www.microsoft.com/provisioning/EapHostConfig">
                        <Eap xmlns="http://www.microsoft.com/provisioning/BaseEapConnectionPropertiesV1">
                          <Type>13</Type>
                          <EapType xmlns="http://www.microsoft.com/provisioning/EapTlsConnectionPropertiesV1">
                            <CredentialsSource>
                              <CertificateStore>
                                <SimpleCertSelection>true</SimpleCertSelection>
                              </CertificateStore>
                            </CredentialsSource>
                            <ServerValidation>
                              <DisableUserPromptForServerValidation>true</DisableUserPromptForServerValidation>
                              <ServerNames>SERVERNAMES</ServerNames>
                              <TrustedRootCA>CAHASH</TrustedRootCA>
                            </ServerValidation>
                            <DifferentUsername>false</DifferentUsername>
                            <PerformServerValidation xmlns="http://www.microsoft.com/provisioning/EapTlsConnectionPropertiesV2">true</PerformServerValidation>
                            <AcceptServerName xmlns="http://www.microsoft.com/provisioning/EapTlsConnectionPropertiesV2">true</AcceptServerName>
                            <TLSExtensions xmlns="http://www.microsoft.com/provisioning/EapTlsConnectionPropertiesV2">
                              <FilteringInfo xmlns="http://www.microsoft.com/provisioning/EapTlsConnectionPropertiesV3">
                                <CAHashList Enabled="true">
                                  <IssuerHash>CAHASH</IssuerHash>
                                </CAHashList>
                              </FilteringInfo>
                            </TLSExtensions>
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
