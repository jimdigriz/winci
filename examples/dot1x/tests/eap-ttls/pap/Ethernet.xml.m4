<?xml version="1.0"?>
<LANProfile xmlns="http://www.microsoft.com/networking/LAN/profile/v1">
  <MSM>
    <security>
      <OneXEnforced>true</OneXEnforced>
      <OneXEnabled>true</OneXEnabled>
      <OneX xmlns="http://www.microsoft.com/networking/OneX/v1">
        <cacheUserData>true</cacheUserData>
        <authMode>user</authMode>
        <EAPConfig>
          <EapHostConfig xmlns="http://www.microsoft.com/provisioning/EapHostConfig">
            <EapMethod>
              <Type xmlns="http://www.microsoft.com/provisioning/EapCommon">21</Type>
              <VendorId xmlns="http://www.microsoft.com/provisioning/EapCommon">0</VendorId>
              <VendorType xmlns="http://www.microsoft.com/provisioning/EapCommon">0</VendorType>
              <AuthorId xmlns="http://www.microsoft.com/provisioning/EapCommon">311</AuthorId>
            </EapMethod>
            <Config xmlns="http://www.microsoft.com/provisioning/EapHostConfig">
              <EapTtls xmlns="http://www.microsoft.com/provisioning/EapTtlsConnectionPropertiesV1">
                <ServerValidation>
                  <ServerNames>SERVERNAMES</ServerNames>
                  <TrustedRootCAHash>CAHASH</TrustedRootCAHash>
                  <DisablePrompt>true</DisablePrompt>
                </ServerValidation>
                <Phase2Authentication>
                  <PAPAuthentication/>
                </Phase2Authentication>
                <Phase1Identity>
                  <IdentityPrivacy>true</IdentityPrivacy>
                  <AnonymousIdentity>@example.test</AnonymousIdentity>
                </Phase1Identity>
              </EapTtls>
            </Config>
          </EapHostConfig>
        </EAPConfig>
      </OneX>
    </security>
  </MSM>
</LANProfile>
