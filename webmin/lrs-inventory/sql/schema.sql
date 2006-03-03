-- MySQL dump 9.11
--

--
-- Table structure for table `Bios`
--

CREATE TABLE Bios (
  id int(10) unsigned NOT NULL auto_increment,
  Serial varchar(64) default NULL,
  Chipset varchar(32) default NULL,
  BiosVersion varchar(64) default NULL,
  ChipSerial varchar(32) default NULL,
  ChipVendor varchar(32) default NULL,
  BiosVendor varchar(64) default NULL,
  TypeMachine varchar(32) default NULL,
  SmbManufacturer varchar(32) default NULL,
  SmbProduct varchar(32) default NULL,
  SmbVersion varchar(32) default NULL,
  SmbSerial varchar(32) default NULL,
  SmbUUID varchar(32) default NULL,
  SmbType varchar(32) default NULL,
  PRIMARY KEY  (id)
) TYPE=MyISAM;

--
-- Table structure for table `Controller`
--

CREATE TABLE Controller (
  id int(10) unsigned NOT NULL auto_increment,
  Vendor varchar(32) default NULL,
  ExpandedType varchar(16) default NULL,
  HardwareVersion varchar(16) default NULL,
  StandardType varchar(16) default NULL,
  PRIMARY KEY  (id)
) TYPE=MyISAM;

--
-- Table structure for table `CustomField`
--

CREATE TABLE CustomField (
  id mediumint(9) unsigned NOT NULL auto_increment,
  machine mediumint(9) unsigned NOT NULL default '0',
  Field varchar(32) NOT NULL default '',
  Value varchar(255) NOT NULL default '',
  PRIMARY KEY  (id),
  KEY machine (machine),
  KEY Keyf (Field)
) TYPE=MyISAM;

--
-- Table structure for table `Drive` (Logical drives)
--

CREATE TABLE Drive (
  id int(11) unsigned NOT NULL auto_increment,
  DriveLetter varchar(4) default NULL,
  DriveType varchar(32) default NULL,
  TotalSpace mediumint(16) default NULL,
  FreeSpace mediumint(16) default NULL,
  VolumeName varchar(16) default NULL,
  FileSystem varchar(16) default NULL,
  FileCount mediumint(16) default NULL,
  PRIMARY KEY  (id)
) TYPE=MyISAM;

--
-- Table structure for table `Hardware`
--

CREATE TABLE Hardware (
  id int(11) unsigned NOT NULL auto_increment,
  OperatingSystem varchar(64) default NULL,
  Version varchar(16) default NULL,
  Build varchar(32) default NULL,
  ProcessorType varchar(128) default NULL,
  ProcessorFrequency varchar(8) default NULL,
  ProcessorCount tinyint(2) default NULL,
  RamTotal varchar(8) default NULL,
  SwapSpace varchar(8) default NULL,
  IpAddress varchar(16) default NULL,
  Date date default NULL,
  User varchar(32) default NULL,
  Workgroup varchar(32) default NULL,
  RegisteredName varchar(32) default NULL,
  RegisteredCompany varchar(32) default NULL,
  OSSerialNumber varchar(32) default NULL,
  PRIMARY KEY  (id)
) TYPE=MyISAM;

--
-- Table structure for table `Input`
--

CREATE TABLE Input (
  id int(11) unsigned NOT NULL auto_increment,
  Type varchar(32) default NULL,
  StandardDescription varchar(128) default NULL,
  ExpandedDescription varchar(128) default NULL,
  Connector varchar(8) default NULL,
  PRIMARY KEY  (id)
) TYPE=MyISAM;

--
-- Table structure for table `Inventory`
--

CREATE TABLE Inventory (
  id mediumint(8) unsigned NOT NULL auto_increment,
  Date date NOT NULL default '0000-00-00',
  Time time NOT NULL default '00:00:00',
  PRIMARY KEY  (id)
) TYPE=MyISAM;

--
-- Table structure for table `Machine`
--

CREATE TABLE Machine (
  id mediumint(9) unsigned NOT NULL auto_increment,
  Name varchar(32) default NULL,
  PRIMARY KEY  (id)
) TYPE=MyISAM;

--
-- Table structure for table `Memory`
--

CREATE TABLE Memory (
  id int(11) unsigned NOT NULL auto_increment,
  ExtendedDescription varchar(32) default NULL,
  Size mediumint(8) default NULL,
  ChipsetType varchar(32) default NULL,
  Frequency varchar(8) default NULL,
  SlotCount mediumint(8) default NULL,
  PRIMARY KEY  (id)
) TYPE=MyISAM;

--
-- Table structure for table `Modem`
--

CREATE TABLE Modem (
  id int(11) unsigned NOT NULL auto_increment,
  Vendor varchar(32) default NULL,
  ExpandedDescription varchar(32) default NULL,
  Type varchar(32) default NULL,
  PRIMARY KEY  (id)
) TYPE=MyISAM;

--
-- Table structure for table `Monitor`
--

CREATE TABLE Monitor (
  id int(11) unsigned NOT NULL auto_increment,
  Stamp varchar(32) default NULL,
  Description varchar(32) default NULL,
  Type varchar(16) default NULL,
  PRIMARY KEY  (id)
) TYPE=MyISAM;

--
-- Table structure for table `Network`
--

CREATE TABLE Network (
  id int(11) unsigned NOT NULL auto_increment,
  CardType varchar(64) default NULL,
  NetworkType varchar(32) default NULL,
  MIB varchar(32) default NULL,
  Bandwidth varchar(16) default NULL,
  MACAddress varchar(32) default NULL,
  State varchar(8) default NULL,
  IP varchar(16) default NULL,
  SubnetMask varchar(16) default NULL,
  Gateway varchar(16) default NULL,
  DNS varchar(16) default NULL,
  PRIMARY KEY  (id)
) TYPE=MyISAM;

--
-- Table structure for table `Pci`
--

CREATE TABLE Pci (
  id int(11) unsigned NOT NULL auto_increment,
  Bus int(11) default NULL,
  Func varchar(8) default NULL,
  Vendor varchar(32) default NULL,
  Device varchar(128) default NULL,
  Class varchar(32) default NULL,
  Type varchar(32) default NULL,  
  PRIMARY KEY  (id)
) TYPE=MyISAM;

--
-- Table structure for table `Port`
--

CREATE TABLE Port (
  id int(11) unsigned NOT NULL auto_increment,
  Stamp varchar(16) default NULL,
  Type varchar(16) default NULL,
  PRIMARY KEY  (id)
) TYPE=MyISAM;

--
-- Table structure for table `Printer`
--

CREATE TABLE Printer (
  id int(11) unsigned NOT NULL auto_increment,
  Name varchar(32) default NULL,
  Driver varchar(64) default NULL,
  Port varchar(64) default NULL,
  PRIMARY KEY  (id)
) TYPE=MyISAM;

--
-- Table structure for table `Slot`
--

CREATE TABLE Slot (
  id int(11) unsigned NOT NULL auto_increment,
  Connector varchar(8) default NULL,
  PortType varchar(16) default NULL,
  Availability varchar(16) default NULL,
  State varchar(8) default NULL,
  PRIMARY KEY  (id)
) TYPE=MyISAM;

--
-- Table structure for table `Software`
--

CREATE TABLE Software (
  id int(11) unsigned NOT NULL auto_increment,
  ProductPath varchar(255) default NULL,
  ProductName varchar(64) default NULL,
  ExecutableSize int(10) unsigned default NULL,
  Company varchar(32) default NULL,
  Application varchar(32) default NULL,
  Type varchar(32) default NULL,
  ProductVersion varchar(16) default NULL,
  PRIMARY KEY  (id)
) TYPE=MyISAM;

--
-- Table structure for table `Sound`
--

CREATE TABLE Sound (
  id int(11) unsigned NOT NULL auto_increment,
  Name varchar(64) default NULL,
  Description varchar(128) default NULL,
  PRIMARY KEY  (id)
) TYPE=MyISAM;

--
-- Table structure for table `Storage`
--

CREATE TABLE Storage (
  id int(11) unsigned NOT NULL auto_increment,
  ExtendedType varchar(32) default NULL,
  Model varchar(32) default NULL,
  VolumeName varchar(32) default NULL,
  Media varchar(32) default NULL,
  StandardType varchar(32) default NULL,
  PRIMARY KEY  (id)
) TYPE=MyISAM;

--
-- Table structure for table `Version`
--

CREATE TABLE Version (
  Number tinyint(4) unsigned NOT NULL default '0'
) TYPE=MyISAM;

--
-- Table structure for table `VideoCard`
--

CREATE TABLE VideoCard (
  id int(11) unsigned NOT NULL auto_increment,
  Model varchar(255) default NULL,
  Chipset varchar(255) default NULL,
  VRAMSize mediumint(8) default NULL,
  Resolution varchar(255) default NULL,
  PRIMARY KEY  (id)
) TYPE=MyISAM;

--
-- Table structure for table `hasBios`
--

CREATE TABLE hasBios (
  machine mediumint(9) unsigned NOT NULL default '0',
  inventory mediumint(5) unsigned NOT NULL default '0',
  bios int(11) unsigned NOT NULL default '0',
  PRIMARY KEY  (machine,inventory,bios)
) TYPE=MyISAM;

--
-- Table structure for table `hasController`
--

CREATE TABLE hasController (
  machine mediumint(9) unsigned NOT NULL default '0',
  inventory mediumint(5) unsigned NOT NULL default '0',
  controller int(11) unsigned NOT NULL default '0',
  PRIMARY KEY  (machine,inventory,controller)
) TYPE=MyISAM;

--
-- Table structure for table `hasDrive`
--

CREATE TABLE hasDrive (
  machine mediumint(9) unsigned NOT NULL default '0',
  inventory mediumint(5) unsigned NOT NULL default '0',
  drive int(11) unsigned NOT NULL default '0',
  PRIMARY KEY  (machine,inventory,drive)
) TYPE=MyISAM;

--
-- Table structure for table `hasHardware`
--

CREATE TABLE hasHardware (
  machine mediumint(9) unsigned NOT NULL default '0',
  inventory mediumint(5) unsigned NOT NULL default '0',
  hardware int(11) unsigned NOT NULL default '0',
  PRIMARY KEY  (machine,inventory,hardware)
) TYPE=MyISAM;

--
-- Table structure for table `hasInput`
--

CREATE TABLE hasInput (
  machine mediumint(9) unsigned NOT NULL default '0',
  inventory mediumint(5) unsigned NOT NULL default '0',
  input int(11) unsigned NOT NULL default '0',
  PRIMARY KEY  (machine,inventory,input)
) TYPE=MyISAM;

--
-- Table structure for table `hasMemory`
--

CREATE TABLE hasMemory (
  machine mediumint(9) unsigned NOT NULL default '0',
  inventory mediumint(5) unsigned NOT NULL default '0',
  memory int(11) unsigned NOT NULL default '0',
  PRIMARY KEY  (machine,inventory,memory)
) TYPE=MyISAM;

--
-- Table structure for table `hasModem`
--

CREATE TABLE hasModem (
  machine mediumint(9) unsigned NOT NULL default '0',
  inventory mediumint(5) unsigned NOT NULL default '0',
  modem int(11) unsigned NOT NULL default '0',
  PRIMARY KEY  (machine,inventory,modem)
) TYPE=MyISAM;

--
-- Table structure for table `hasMonitor`
--

CREATE TABLE hasMonitor (
  machine mediumint(9) unsigned NOT NULL default '0',
  inventory mediumint(5) unsigned NOT NULL default '0',
  monitor int(11) unsigned NOT NULL default '0',
  PRIMARY KEY  (machine,inventory,monitor)
) TYPE=MyISAM;

--
-- Table structure for table `hasNetwork`
--

CREATE TABLE hasNetwork (
  machine mediumint(9) unsigned NOT NULL default '0',
  inventory mediumint(5) unsigned NOT NULL default '0',
  network int(11) unsigned NOT NULL default '0',
  PRIMARY KEY  (machine,inventory,network)
) TYPE=MyISAM;

--
-- Table structure for table `hasPci`
--

CREATE TABLE hasPci (
  machine mediumint(9) unsigned NOT NULL default '0',
  inventory mediumint(5) unsigned NOT NULL default '0',
  pci int(11) unsigned NOT NULL default '0',
  PRIMARY KEY  (machine,inventory,pci)
) TYPE=MyISAM;


--
-- Table structure for table `hasPort`
--

CREATE TABLE hasPort (
  machine mediumint(9) unsigned NOT NULL default '0',
  inventory mediumint(5) unsigned NOT NULL default '0',
  port int(11) unsigned NOT NULL default '0',
  PRIMARY KEY  (machine,inventory,port)
) TYPE=MyISAM;

--
-- Table structure for table `hasPrinter`
--

CREATE TABLE hasPrinter (
  machine mediumint(9) unsigned NOT NULL default '0',
  inventory mediumint(5) unsigned NOT NULL default '0',
  printer int(11) unsigned NOT NULL default '0',
  PRIMARY KEY  (machine,inventory,printer)
) TYPE=MyISAM;

--
-- Table structure for table `hasSlot`
--

CREATE TABLE hasSlot (
  machine mediumint(9) unsigned NOT NULL default '0',
  inventory mediumint(5) unsigned NOT NULL default '0',
  slots int(11) unsigned NOT NULL default '0',
  PRIMARY KEY  (machine,inventory,slots)
) TYPE=MyISAM;

--
-- Table structure for table `hasSoftware`
--

CREATE TABLE hasSoftware (
  machine mediumint(9) unsigned NOT NULL default '0',
  inventory mediumint(5) unsigned NOT NULL default '0',
  software int(11) unsigned NOT NULL default '0',
  PRIMARY KEY  (machine,inventory,software)
) TYPE=MyISAM;

--
-- Table structure for table `hasSound`
--

CREATE TABLE hasSound (
  machine mediumint(9) unsigned NOT NULL default '0',
  inventory mediumint(5) unsigned NOT NULL default '0',
  sound int(11) unsigned NOT NULL default '0',
  PRIMARY KEY  (machine,inventory,sound)
) TYPE=MyISAM;

--
-- Table structure for table `hasStorage`
--

CREATE TABLE hasStorage (
  machine mediumint(9) unsigned NOT NULL default '0',
  inventory mediumint(5) unsigned NOT NULL default '0',
  storage int(11) unsigned NOT NULL default '0',
  PRIMARY KEY  (machine,inventory,storage)
) TYPE=MyISAM;

--
-- Table structure for table `hasVideoCard`
--

CREATE TABLE hasVideoCard (
  machine mediumint(9) unsigned NOT NULL default '0',
  inventory mediumint(5) unsigned NOT NULL default '0',
  videocard int(11) unsigned NOT NULL default '0',
  PRIMARY KEY  (machine,inventory,videocard)
) TYPE=MyISAM;

--
-- Database version
--
INSERT INTO Version VALUES( '1' );
