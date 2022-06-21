<?xml version="1.0" encoding="utf-8"?>
<unattend xmlns="urn:schemas-microsoft-com:unattend">
	<settings pass="windowsPE">
		<component name="Microsoft-Windows-International-Core-WinPE"
				publicKeyToken="31bf3856ad364e35" language="neutral"
				versionScope="nonSxS" processorArchitecture="amd64"
				xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State">
			<SetupUILanguage>
				<UILanguage>LOCALE</UILanguage>
			</SetupUILanguage>
			<InputLocale>LOCALE</InputLocale>
			<SystemLocale>LOCALE</SystemLocale>
			<UILanguage>LOCALE</UILanguage>
			<UILanguageFallback>LOCALE</UILanguageFallback>
			<UserLocale>LOCALE</UserLocale>
		</component>

		<component name="Microsoft-Windows-PnpCustomizationsWinPE"
				publicKeyToken="31bf3856ad364e35" language="neutral"
				versionScope="nonSxS" processorArchitecture="amd64"
				xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State">

			<DriverPaths>
				<PathAndCredentials wcm:action="add" wcm:keyValue="2">
					<Path>E:\Balloon\w11\amd64</Path>
				</PathAndCredentials>
				<PathAndCredentials wcm:action="add" wcm:keyValue="3">
					<Path>E:\fwcfg\w11\amd64</Path>
				</PathAndCredentials>
				<PathAndCredentials wcm:action="add" wcm:keyValue="4">
					<Path>E:\NetKVM\w11\amd64</Path>
				</PathAndCredentials>
				<PathAndCredentials wcm:action="add" wcm:keyValue="5">
					<Path>E:\pvpanic\w11\amd64</Path>
				</PathAndCredentials>
				<PathAndCredentials wcm:action="add" wcm:keyValue="6">
					<Path>E:\qemufwcfg\w11\amd64</Path>
				</PathAndCredentials>
				<PathAndCredentials wcm:action="add" wcm:keyValue="7">
					<Path>E:\qemupciserial\w11\amd64</Path>
				</PathAndCredentials>
				<PathAndCredentials wcm:action="add" wcm:keyValue="8">
					<Path>E:\smbus\w11\amd64</Path>
				</PathAndCredentials>
				<PathAndCredentials wcm:action="add" wcm:keyValue="9">
					<Path>E:\sriov\w11\amd64</Path>
				</PathAndCredentials>
				<PathAndCredentials wcm:action="add" wcm:keyValue="10">
					<Path>E:\viofs\w11\amd64</Path>
				</PathAndCredentials>
				<PathAndCredentials wcm:action="add" wcm:keyValue="11">
					<Path>E:\viogpudo\w11\amd64</Path>
				</PathAndCredentials>
				<PathAndCredentials wcm:action="add" wcm:keyValue="12">
					<Path>E:\vioinput\w11\amd64</Path>
				</PathAndCredentials>
				<PathAndCredentials wcm:action="add" wcm:keyValue="13">
					<Path>E:\viorng\w11\amd64</Path>
				</PathAndCredentials>
				<PathAndCredentials wcm:action="add" wcm:keyValue="14">
					<Path>E:\vioserial\w11\amd64</Path>
				</PathAndCredentials>
				<PathAndCredentials wcm:action="add" wcm:keyValue="15">
					<Path>E:\viostor\w11\amd64</Path>
				</PathAndCredentials>
			</DriverPaths>
		</component>

		<component name="Microsoft-Windows-Setup"
				publicKeyToken="31bf3856ad364e35" language="neutral"
				versionScope="nonSxS" processorArchitecture="amd64"
				xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State">
			<UserData>
				<AcceptEula>true</AcceptEula>
				<ProductKey>
					<Key />
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
					<WillWipeDisk>true</WillWipeDisk>

					<CreatePartitions>
						<CreatePartition wcm:action="add">
							<Order>1</Order>
							<Type>Primary</Type>
							<Extend>true</Extend>
						</CreatePartition>
					</CreatePartitions>

					<ModifyPartitions>
						<ModifyPartition wcm:action="add">
							<Order>1</Order>
							<PartitionID>1</PartitionID>
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
							<Value>Windows 11 Pro</Value>
						</MetaData>
					</InstallFrom>
					<InstallTo>
						<DiskID>0</DiskID>
						<PartitionID>1</PartitionID>
					</InstallTo>
				</OSImage>
			</ImageInstall>
		</component>
	</settings>

        <settings pass="generalize">
		<component name="Microsoft-Windows-PnpSysprep"
				publicKeyToken="31bf3856ad364e35" language="neutral"
				versionScope="nonSxS" processorArchitecture="amd64"
				xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State">
			<PersistAllDeviceInstalls>true</PersistAllDeviceInstalls>
		</component>
	</settings>

        <settings pass="specialize">
		<component name="Microsoft-Windows-Setup"
				publicKeyToken="31bf3856ad364e35" language="neutral"
				versionScope="nonSxS" processorArchitecture="amd64"
				xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State">
			<ComputerName>`W'VERSION-COMMITID</ComputerName>
		</component>
	</settings>

	<settings pass="oobeSystem">
		<component name="Microsoft-Windows-International-Core"
				publicKeyToken="31bf3856ad364e35" language="neutral"
				versionScope="nonSxS" processorArchitecture="amd64"
				xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State">
			<InputLocale>LOCALE</InputLocale>
			<SystemLocale>LOCALE</SystemLocale>
			<UILanguage>LOCALE</UILanguage>
			<UserLocale>LOCALE</UserLocale>
		</component>

		<component name="Microsoft-Windows-Shell-Setup"
				publicKeyToken="31bf3856ad364e35" language="neutral"
				versionScope="nonSxS" processorArchitecture="amd64"
				xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State">
			<UserAccounts>
				<AdministratorPassword>
					<Value>PASSWORD</Value>
					<PlainText>true</PlainText>
				</AdministratorPassword>
			</UserAccounts>
			<AutoLogon>
				<Username>USERNAME</Username>
				<Enabled>true</Enabled>
				<LogonCount>1</LogonCount>
				<Password>
					<Value>PASSWORD</Value>
					<PlainText>true</PlainText>
				</Password>
			</AutoLogon>
			<OOBE>
				<HideEULAPage>true</HideEULAPage>
				<ProtectYourPC>3</ProtectYourPC>
			</OOBE>
			<TimeZone>UTC</TimeZone>
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
</unattend>
