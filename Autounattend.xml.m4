<?xml version="1.0" encoding="utf-8"?>
<!-- Answer files (unattend.xml) - https://docs.microsoft.com/windows-hardware/manufacture/desktop/update-windows-settings-and-scripts-create-your-own-answer-file-sxs -->
<!-- Unattended Windows Setup Reference - https://docs.microsoft.com/windows-hardware/customize/desktop/unattend/ -->
<!-- Windows Templates for Packer - https://github.com/StefanScherer/packer-windows -->
<!-- Unattend Generator - https://schneegans.de/windows/unattend-generator/ -->
<unattend xmlns="urn:schemas-microsoft-com:unattend" xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State">
	<settings pass="windowsPE">
		<component name="Microsoft-Windows-International-Core-WinPE"
				publicKeyToken="31bf3856ad364e35" language="neutral"
				versionScope="nonSxS" processorArchitecture="amd64">
			<SetupUILanguage>
				<UILanguage>LOCALE</UILanguage>
			</SetupUILanguage>
			<InputLocale>LOCALE</InputLocale>
			<SystemLocale>LOCALE</SystemLocale>
			<UILanguage>LOCALE</UILanguage>
			<UILanguageFallback>en-us</UILanguageFallback>
			<UserLocale>LOCALE</UserLocale>
		</component>

		<component name="Microsoft-Windows-PnpCustomizationsWinPE"
				publicKeyToken="31bf3856ad364e35" language="neutral"
				versionScope="nonSxS" processorArchitecture="amd64">
			<!-- cat data/info.json | jq -r '.drivers[] | select(.arch == "amd64" and .windows_version == "w11") | .inf_path' | xargs dirname | sort -u | grep -v qxldod -->
			<DriverPaths>
				<PathAndCredentials wcm:action="add" wcm:keyValue="2">
					<Path>E:\Balloon\`w'WINVER\amd64</Path>
				</PathAndCredentials>
				<PathAndCredentials wcm:action="add" wcm:keyValue="3">
					<Path>E:\fwcfg\`w'WINVER\amd64</Path>
				</PathAndCredentials>
				<PathAndCredentials wcm:action="add" wcm:keyValue="4">
					<Path>E:\NetKVM\`w'WINVER\amd64</Path>
				</PathAndCredentials>
				<PathAndCredentials wcm:action="add" wcm:keyValue="5">
					<Path>E:\pvpanic\`w'WINVER\amd64</Path>
				</PathAndCredentials>
ifelse(WINVER, `10', dnl Causes Windows 11 install to fail with: Error code: 0x80070103 - 0x40031
				<PathAndCredentials wcm:action="add" wcm:keyValue="6">
					<Path>E:\qemufwcfg\`w'WINVER\amd64</Path>
				</PathAndCredentials>
				<PathAndCredentials wcm:action="add" wcm:keyValue="7">
					<Path>E:\smbus\`w'WINVER\amd64</Path>
				</PathAndCredentials>)
				<PathAndCredentials wcm:action="add" wcm:keyValue="8">
					<Path>E:\viofs\`w'WINVER\amd64</Path>
				</PathAndCredentials>
				<PathAndCredentials wcm:action="add" wcm:keyValue="9">
					<Path>E:\viogpudo\`w'WINVER\amd64</Path>
				</PathAndCredentials>
				<PathAndCredentials wcm:action="add" wcm:keyValue="10">
					<Path>E:\vioinput\`w'WINVER\amd64</Path>
				</PathAndCredentials>
				<PathAndCredentials wcm:action="add" wcm:keyValue="11">
					<Path>E:\viomem\`w'WINVER\amd64</Path>
				</PathAndCredentials>
				<PathAndCredentials wcm:action="add" wcm:keyValue="12">
					<Path>E:\viorng\`w'WINVER\amd64</Path>
				</PathAndCredentials>
				<PathAndCredentials wcm:action="add" wcm:keyValue="13">
					<Path>E:\vioscsi\`w'WINVER\amd64</Path>
				</PathAndCredentials>
				<PathAndCredentials wcm:action="add" wcm:keyValue="14">
					<Path>E:\vioserial\`w'WINVER\amd64</Path>
				</PathAndCredentials>
				<PathAndCredentials wcm:action="add" wcm:keyValue="15">
					<Path>E:\viostor\`w'WINVER\amd64</Path>
				</PathAndCredentials>
			</DriverPaths>
		</component>

		<component name="Microsoft-Windows-Setup"
				publicKeyToken="31bf3856ad364e35" language="neutral"
				versionScope="nonSxS" processorArchitecture="amd64">
			<UserData>
				<AcceptEula>true</AcceptEula>
				<ProductKey>
					<Key/>
					<WillShowUI>OnError</WillShowUI>
				</ProductKey>
			</UserData>

			<RunSynchronous>
				<RunSynchronousCommand wcm:action="add">
					<Order>1</Order>
					<Path>reg import A:\Autounattend\LabConfig.reg</Path>
				</RunSynchronousCommand>
			</RunSynchronous>

			<DiskConfiguration>
				<Disk wcm:action="add">
					<DiskID>0</DiskID>
					<CreatePartitions>
						<CreatePartition wcm:action="add">
							<Order>1</Order>
							<Type>Primary</Type>
							<Size>300</Size>
						</CreatePartition>
						<CreatePartition wcm:action="add">
							<Order>2</Order>
							<Type>Primary</Type>
							<Extend>true</Extend>
						</CreatePartition>
					</CreatePartitions>
					<ModifyPartitions>
						<ModifyPartition wcm:action="add">
							<Order>1</Order>
							<PartitionID>1</PartitionID>
							<Label>System</Label>
							<Format>NTFS</Format>
							<Active>true</Active>
						</ModifyPartition>
						<ModifyPartition wcm:action="add">
							<Order>2</Order>
							<PartitionID>2</PartitionID>
							<Label>Windows</Label>
							<Letter>C</Letter>
							<Format>NTFS</Format>
						</ModifyPartition>
					</ModifyPartitions>
				</Disk>
				<WillShowUI>OnError</WillShowUI>
			</DiskConfiguration>

			<ImageInstall>
				<OSImage>
					<InstallFrom>
						<MetaData wcm:action="add">
							<Key>/IMAGE/Description</Key>
							<Value>Windows WINVER Pro</Value>
						</MetaData>
					</InstallFrom>
					<InstallTo>
						<DiskID>0</DiskID>
						<PartitionID>2</PartitionID>
					</InstallTo>
				</OSImage>
			</ImageInstall>
		</component>
	</settings>

	<settings pass="offlineServicing">
		<component name="Microsoft-Windows-LUA-Settings"
				publicKeyToken="31bf3856ad364e35" language="neutral"
				versionScope="nonSxS" processorArchitecture="amd64">
			<EnableLUA>false</EnableLUA>
		</component>
	</settings>

	<settings pass="oobeSystem">
		<component name="Microsoft-Windows-International-Core"
				publicKeyToken="31bf3856ad364e35" language="neutral"
				versionScope="nonSxS" processorArchitecture="amd64">
			<InputLocale>LOCALE</InputLocale>
			<SystemLocale>LOCALE</SystemLocale>
			<UILanguage>LOCALE</UILanguage>
			<UserLocale>LOCALE</UserLocale>
		</component>

		<component name="Microsoft-Windows-Shell-Setup"
				publicKeyToken="31bf3856ad364e35" language="neutral"
				versionScope="nonSxS" processorArchitecture="amd64">
			<UserAccounts>
				<AdministratorPassword>
					<Value>PASSWORD</Value>
					<PlainText>true</PlainText>
				</AdministratorPassword>
			</UserAccounts>
			<OOBE>
				<HideEULAPage>true</HideEULAPage>
				<HideWirelessSetupInOOBE>true</HideWirelessSetupInOOBE>
				<ProtectYourPC>3</ProtectYourPC>
			</OOBE>
			<AutoLogon>
				<Username>Administrator</Username>
				<Enabled>true</Enabled>
				<Password>
					<Value>PASSWORD</Value>
					<PlainText>true</PlainText>
				</Password>
				<LogonCount>1</LogonCount>
			</AutoLogon>
			<FirstLogonCommands>
				<!-- WinRM only works for Private networks and <NetworkLocation> no longer works -->
				<SynchronousCommand>
					<Order>1</Order>
					<CommandLine>powershell.exe -Command "Get-NetConnectionProfile | ForEach-Object { Set-NetConnectionProfile -InterfaceIndex $_.InterfaceIndex -NetworkCategory Private }"</CommandLine>
				</SynchronousCommand>
				<SynchronousCommand wcm:action="add">
					<Order>2</Order>
					<CommandLine>A:\Autounattend\winrmConfig.bat</CommandLine>
				</SynchronousCommand>
			</FirstLogonCommands>
		</component>
	</settings>

	<settings pass="generalize">
		<component name="Microsoft-Windows-PnpSysprep"
				publicKeyToken="31bf3856ad364e35" language="neutral"
				versionScope="nonSxS" processorArchitecture="amd64">
			<PersistAllDeviceInstalls>true</PersistAllDeviceInstalls>
		</component>
	</settings>

	<settings pass="specialize">
		<component name="Microsoft-Windows-Shell-Setup"
				publicKeyToken="31bf3856ad364e35" language="neutral"
				versionScope="nonSxS" processorArchitecture="amd64">
			<OEMInformation>
				<HelpCustomized>false</HelpCustomized>
			</OEMInformation>
			<ComputerName>`W'WINVER-VERSION</ComputerName>
			<TimeZone>UTC</TimeZone>
			<RegisteredOwner/>
		</component>
		<component name="Microsoft-Windows-Security-SPP-UX"
				publicKeyToken="31bf3856ad364e35" language="neutral"
				versionScope="nonSxS" processorArchitecture="amd64">
			<SkipAutoActivation>true</SkipAutoActivation>
		</component>

		<!-- https://matthewvaneerde.wordpress.com/2012/03/15/unattend-xml-turning-on-remote-desktop-automatically/ -->
		<component name="Microsoft-Windows-TerminalServices-LocalSessionManager"
				publicKeyToken="31bf3856ad364e35" language="neutral"
				versionScope="nonSxS" processorArchitecture="amd64">
			<fDenyTSConnections>false</fDenyTSConnections>
		</component>
		<component name="Networking-MPSSVC-Svc"
				publicKeyToken="31bf3856ad364e35" language="neutral"
				versionScope="nonSxS" processorArchitecture="amd64">
			<FirewallGroups>
				<FirewallGroup wcm:action="add" wcm:keyValue="RemoteDesktop">
					<Active>true</Active>
					<Group>@FirewallAPI.dll,-28752</Group>
					<Profile>all</Profile>
				</FirewallGroup>
			</FirewallGroups>
		</component>
	</settings>
</unattend>
